class CustomTable < ActiveRecord::Base
  unloadable
  include Redmine::SafeAttributes

  belongs_to :project
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  has_many :custom_fields, dependent: :destroy
  has_many :custom_entities, dependent: :destroy
  has_one :custom_entity

  acts_as_nested_set

  store :settings, accessors: [:main_custom_field_id], coder: JSON

  scope :sorted, lambda { order("#{table_name}.name ASC") }

  scope :like, lambda {|arg|
    if arg.present?
      pattern = "%#{arg.to_s.strip}%"
      where("LOWER(name) LIKE LOWER(:p)", p: pattern)
    end
  }

  safe_attributes 'name', 'project_id', 'author_id', 'main_custom_field_id'

  attr_protected :id

  validates :name, presence: true, uniqueness: true

  acts_as_customizable

  def css_classes
    s = 'project'
    s << ' root' if root?
    s << ' child' if child?
    s << (leaf? ? ' leaf' : ' parent')
    s
  end

  def self.visible?
    @visible ||= User.current.allowed_to?(:show_tables, nil, global: true)
  end

  def visible?
    self.class.visible?
  end

  def self.editable?
    @editable ||= User.current.allowed_to?(:manage_tables, nil, global: true)
  end

  def editable?
    self.class.editable?
  end

  def self.deletable?
    @deletable ||= User.current.allowed_to?(:manage_tables, nil, global: true)
  end

  def deletable?
    self.class.deletable?
  end

  def main_custom_field
    if main_custom_field_id.present? && (custom_field = CustomField.find_by(id: main_custom_field_id))
      custom_field
    else
      custom_fields.first
    end
  end
end
