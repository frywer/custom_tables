class CustomTable < ActiveRecord::Base
  include Redmine::SafeAttributes

  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  has_many :custom_fields, dependent: :destroy
  has_many :custom_entities, dependent: :destroy
  has_one :custom_entity
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :trackers
  has_and_belongs_to_many :roles

  acts_as_nested_set

  store :settings, accessors: [:main_custom_field_id], coder: JSON

  scope :sorted, lambda { order("#{table_name}.name ASC") }

  scope :like, lambda {|arg|
    if arg.present?
      pattern = "%#{arg.to_s.strip}%"
      where("LOWER(name) LIKE LOWER(:p)", p: pattern)
    end
  }

  scope :visible, lambda {|*args|
    user = args.shift || User.current
    if user.admin?
      # nop
    elsif user.memberships.any?
      where("#{table_name}.visible = ? OR #{table_name}.id IN (SELECT DISTINCT cfr.custom_table_id FROM #{Member.table_name} m" +
                " INNER JOIN #{MemberRole.table_name} mr ON mr.member_id = m.id" +
                " INNER JOIN #{table_name_prefix}custom_tables_roles#{table_name_suffix} cfr ON cfr.role_id = mr.role_id" +
                " WHERE m.user_id = ?)",
            true, user.id)
    else
      where(:visible => true)
    end
  }

  safe_attributes 'name', 'author_id', 'main_custom_field_id', 'project_ids', 'is_for_all', 'description', 'tracker_ids', 'role_ids', 'visible'

  validates :name, presence: true, uniqueness: true

  acts_as_customizable

  def css_classes
    s = 'project'
    s << ' root' if root?
    s << ' child' if child?
    s << (leaf? ? ' leaf' : ' parent')
    s
  end

  def main_custom_field
    CustomField.find_by(id: main_custom_field_id) || custom_fields.first
  end

  def query(totalable_all: false)
    query = CustomEntityQuery.new(name: '_', custom_table_id: id)
    visible_cfs = custom_fields.visible.sorted
    query.column_names ||= visible_cfs.map {|i| "cf_#{i.id}"}
    if totalable_all
      query.totalable_names = visible_cfs.select(&:totalable?).map {|i| "cf_#{i.id}"}
    end
    query
  end

end
