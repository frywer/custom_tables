class CustomEntity < ActiveRecord::Base
  include Redmine::SafeAttributes
  include CustomTables::ActsAsJournalize

  belongs_to :custom_table
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  belongs_to :issue
  has_one :project, through: :issue
  has_many :custom_fields, through: :custom_table

  safe_attributes 'custom_table_id', 'author_id', 'custom_field_values', 'custom_fields', 'parent_entity_ids',
                  'sub_entity_ids', 'issue_id', 'external_values'

  acts_as_customizable

  delegate :main_custom_field, to: :custom_table

  acts_as_watchable

  self.journal_options = {}

  def name
    if new_record?
      custom_table.name
    else
      custom_value = custom_values.detect { |cv| cv.custom_field == custom_table.main_custom_field }
      custom_value.try(:value) || '---'
    end
  end

  def editable?(user = User.current)
    return true if user.admin? || custom_table.is_for_all
    user.allowed_to?(:edit_issues, issue.project)
  end

  def visible?(user = User.current)
    user.allowed_to?(:view_and_manage_entities, nil, global: true)
  end

  def deletable?(user = nil)
    editable?
  end

  def leaf?
    false
  end

  def is_descendant_of?(p)
    false
  end

  def each_notification(users, &block)
  end

  def notified_users
    []
  end

  def attachments
    []
  end

  def available_custom_fields
    custom_fields.sorted.to_a
  end

  def created_on
    created_at
  end

  def updated_on
    updated_at
  end

  def value_by_external_name(external_name)
    custom_field_values.detect {|v| v.custom_field.external_name == external_name}.try(:value)
  end

  def external_values=(values)
    custom_field_values.each do |custom_field_value|
      key = custom_field_value.custom_field.external_name
      next unless key.present?
      if values.has_key?(key)
        custom_field_value.value = values[key]
      end
    end
    @custom_field_values_changed = true
  end

  def to_h
    values = {}
    custom_field_values.each do |value|
      values[value.custom_field.external_name] = value.value if value.custom_field.external_name.present?
    end
    values["id"] = id
    values
  end

end
