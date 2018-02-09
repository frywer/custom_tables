class CustomEntityCustomField < CustomField

  has_many :custom_entities, through: :custom_table, source: :custom_entity

  validates :custom_table_id, presence: true

  before_destroy :clean_values!

  def belongs_to_format?
    field_format == 'belongs_to'
  end

  def clean_values!
    if belongs_to_format?
      sub_entities = CustomEntity.where(id: custom_values.map(&:customized_id))
      customized_entities = CustomEntity.where(id: custom_values.map(&:value))
      customized_entities.each do |entity|
        couples = entity.sub_entities & sub_entities
        entity.sub_entities.delete(couples) if couples.any?
      end
    end
    custom_values.destroy_all
  end

  def external_name
    super || name.downcase.singularize.gsub(/[^0-9A-Za-z]/, '_')
  end
end