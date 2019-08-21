FactoryBot.define do

  factory :project do
    sequence(:name) { |n| "Project-##{n}" }
    sequence(:identifier) { |n| "project#{n}" }

    after :create do |project, evaluator|
      project.enabled_module_names = Redmine::Plugin.all.map(&:id)
    end
  end

  factory :custom_table do
    sequence(:name) { |n| "Table-##{n}" }
    association :author, factory: :user
  end

  factory :custom_entity do
    association :author, factory: :user
    association :custom_table, factory: :custom_table
  end

  factory :custom_value do
    customized_type { 'CustomEntity' }
    association :customized, factory: :custom_entity
    association :custom_field, factory: :custom_field
    sequence(:value) { |n| "value-##{n}" }
  end

  factory :custom_field do
    type { 'CustomEntityCustomField' }
    sequence(:name) { |n| "Name-3213#{n}" }
    field_format { 'string' }
    possible_values { nil }
    regexp { '' }
    min_length { nil }
    max_length { nil }
    is_required { false }
    is_for_all { false }
    is_filter { true }
    sequence(:position) { |n| n }
    searchable { false }
    default_value { '0' }
    editable { true }
    visible { true }
    multiple { false }
    description { '' }
    parent_table_id { nil }
  end

  factory :user_custom_field, parent: :custom_field do
    field_format { 'user' }
    default_value { nil }
  end

  factory :user, aliases: [:author]  do
    firstname { 'John' }
    sequence(:lastname) { |n| 'Doe' + n.to_s }
    login { "#{firstname}-#{lastname}".downcase }
    sequence(:mail) { |n| "user#{n}@test.com" }
    admin { false }
    language { 'en' }
    status { 1 }
    mail_notification { 'only_my_events' }

    trait :admin do
      firstname { 'Admin' }
      admin { true }
    end

    factory :admin_user, :traits => [:admin]
  end

  factory :query do
    sequence(:name) { |n| "Table-##{n}" }
    association :project, factory: :project
    association :custom_table, factory: :custom_table
    type { 'CustomEntityQuery' }
    visibility { 2 }
  end

  factory :issue_status, :class => 'IssueStatus' do
    sequence(:name){ |n| "TestStatus-#{n}"  }
    default_done_ratio { 100 }

    trait :closed do
      is_closed { true }
    end
  end

  factory :tracker do
    sequence(:name) {|n| "Tracker ##{n}"}
    default_status { IssueStatus.first || FactoryBot.create(:issue_status) }
  end

  factory :issue do
    sequence(:subject) { |n| "Test issue ##{n}" }
    association :project, factory: :project
    tracker { project.trackers.first }
    start_date { Date.today }
    due_date { Date.today + 7.days }
    priority { IssuePriority.default || FactoryBot.create(:issue_priority, :default) }
    association :status, factory: :issue_status
    association :author, :factory => :user, :firstname => "Author"
  end

  factory :enumeration do
    name { 'Test' }

    trait :default do
      name { 'Default' }
      is_default { true }
    end
  end

  factory :role do
    sequence(:name){ |n| "Role ##{n}" }
    permissions { Role.new.setable_permissions.collect(&:name).uniq }
  end

  factory :issue_priority, parent: :enumeration, class: 'IssuePriority' do
    sequence(:name){ |n| "Priority ##{n}" }
  end

  factory :member_role do
    role
    member
  end

  factory :member do
    project
    user
    roles { [] }

    after :build do |member, evaluator|
      if evaluator.roles.empty?
        member.member_roles << FactoryBot.build(:member_role, member: member)
      else
        evaluator.roles.each do |role|
          member.member_roles << FactoryBot.build(:member_role, member: member, role: role)
        end
      end
    end

    trait :without_roles do
      after :create do |member, evaluator|
        member.member_roles.clear
      end
    end
  end
end
