class CustomEntity < ActiveRecord::Base
  unloadable
  include Redmine::SafeAttributes
  include CustomTables::ActsAsJournalize

  belongs_to :custom_table
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  has_one :project, through: :custom_table
  #has_many :custom_fields, through: :custom_table
  #has_many :custom_values, class_name: 'CustomValue', foreign_key: 'customized_id'

  has_and_belongs_to_many :parent_entities,
                          class_name: "CustomEntity",
                          join_table: :related_custom_entities,
                          foreign_key: :sub_entity_id,
                          association_foreign_key: :parent_entity_id

  has_and_belongs_to_many :sub_entities,
                          class_name: "CustomEntity",
                          join_table: :related_custom_entities,
                          foreign_key: :parent_entity_id,
                          association_foreign_key: :sub_entity_id

  safe_attributes 'custom_table_id', 'author_id', 'custom_field_values', 'custom_fields', 'parent_entity_ids', 'sub_entity_ids'

  attr_protected :id
  after_destroy :destroy_values
  acts_as_customizable

  delegate :name, :project, to: :custom_table

  acts_as_watchable

  self.journal_options = {}

  def name
    if new_record?
      custom_table.name
    else
      custom_table.main_custom_field.custom_values.detect { |i| i.customized_id == id }.value || '---'
    end
  end

  def custom_fields
    custom_table.custom_fields
  end

  # TODO fix it
  def visible?(user = nil)
    true
  end

  # TODO fix it
  def editable?(user = User.current)
    true
  end

  # TODO fix it
  def deletable?(user = nil)
    true
  end

  def leaf?
    false
  end

  def is_descendant_of?(p)
    false
  end

  def main_custom_field
    custom_table.main_custom_field
  end

  def each_notification(users, &block)
    # if users.any?
    #   if custom_field_values.detect {|value| !value.custom_field.visible?}
    #     users_by_custom_field_visibility = users.group_by do |user|
    #       visible_custom_field_values.map(&:custom_field_id).sort
    #     end
    #     users_by_custom_field_visibility.values.each do |users|
    #       yield(users)
    #     end
    #   else
    #     yield(users)
    #   end
    # end
  end

  def notes_addable?(user=User.current)
    true
  end

  def attachments
    []
  end

  def available_custom_fields
    CustomField.where("type = 'CustomEntityCustomField' AND custom_table_id = #{custom_table_id}").sorted.to_a
  end

  def created_on
    created_at
  end

  def updated_on
    updated_at
  end

  def visible_custom_field_values
    custom_values
  end

  def custom_field_values
    @custom_field_values ||= available_custom_fields.collect do |field|
      x = CustomFieldValue.new
      x.custom_field = field
      x.customized = self
      if field.multiple?
        values = custom_values.select { |v| v.custom_field == field }
        if values.empty?
          values << custom_values.build(:customized => self, :custom_field => field)
        end
        x.instance_variable_set("@value", values.map(&:value))
      else
        cv = custom_values.detect { |v| v.custom_field == field }
        cv ||= custom_values.build(:customized => self, :custom_field => field)
        x.instance_variable_set("@value", cv.value)
        x.custom_entity_id = cv.custom_entity_id if cv.custom_entity_id.present?
      end
      x.value_was = x.value.dup if x.value
      x
    end
  end

  def custom_field_values=(values)
    values = values.stringify_keys

    custom_field_values.each do |custom_field_value|
      key = custom_field_value.custom_field_id.to_s
      if values.has_key?(key)
        if custom_field_value.custom_field.belongs_to_format? && values[key].present?
          if (custom_entity = CustomEntity.find(values[key]))
            custom_field_value.custom_entity_id = custom_entity.id
            value = custom_entity.name
          end
        else
          value = values[key]
        end
        custom_field_value.value = value
      end
    end
    @custom_field_values_changed = true
  end

  def save_custom_field_values
    target_custom_values = []
    custom_field_values.each do |custom_field_value|
      if custom_field_value.value.is_a?(Array)
        custom_field_value.value.each do |v|
          target = custom_values.detect {|cv| cv.custom_field == custom_field_value.custom_field && cv.value == v}
          target ||= custom_values.build(:customized => self, :custom_field => custom_field_value.custom_field, :value => v)
          target_custom_values << target
        end
      else
        target = custom_values.detect {|cv| cv.custom_field == custom_field_value.custom_field}
        target ||= custom_values.build(:customized => self, :custom_field => custom_field_value.custom_field)
        if custom_field_value.custom_entity_id.present?
          target.custom_entity_id = custom_field_value.custom_entity_id
          target.value = target.custom_entity.name
        else
          target.value = custom_field_value.value
        end
        target_custom_values << target
      end
    end
    self.custom_values = target_custom_values
    custom_values.each(&:save)
    @custom_field_values_changed = false
    true
  end

  def value_by_external_name(external_name)
    custom_field_values.detect {|v| v.custom_field.external_name == external_name}.try(:value)
  end

  private

  def destroy_values
    custom_values.destroy_all
  end

end
