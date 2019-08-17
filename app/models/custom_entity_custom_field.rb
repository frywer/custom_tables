class CustomEntityCustomField < CustomField

  clear_validators!
  validates_presence_of :name, :field_format
  validates_uniqueness_of :name, scope: :custom_table_id
  validates_length_of :name, maximum: 30
  validates_length_of :regexp, maximum: 255
  validates_inclusion_of :field_format, in: Proc.new {Redmine::FieldFormat.available_formats}
  validate :validate_custom_field
  validates :custom_table_id, presence: true

  has_many :custom_entities, through: :custom_table, source: :custom_entity

  belongs_to :custom_table
  belongs_to :parent_table, class_name: 'CustomTable'

  before_create :ensure_position

  safe_attributes 'external_name', 'custom_table_id'

  def belongs_to_format?
    field_format == 'belongs_to'
  end

  private

  def ensure_position
    self.position = custom_table.custom_fields.count.next
  end

end