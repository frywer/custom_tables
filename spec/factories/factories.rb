FactoryGirl.define do

  factory :project do
    sequence(:name){ |n| "Project-##{n}" }
    sequence(:identifier){ |n| "project#{n}" }
  end

  factory :custom_table do
    sequence(:name){ |n| "Table-##{n}" }
    association :project, factory: :project
    association :author, factory: :user
  end

  factory :custom_entity do
    association :author, factory: :user
    association :custom_table, factory: :custom_table
  end

  factory :custom_value do
    customized_type "CustomEntity"
    association :customized, factory: :custom_entity
    association :custom_field, factory: :custom_field
    sequence(:value){ |n| "value-##{n}" }
  end

  factory :custom_field do
    type"CustomEntityCustomField"
    sequence(:name){ |n| "Name-3213#{n}" }
    field_format "string"
    possible_values nil
    regexp ''
    min_length nil
    max_length nil
    is_required false
    is_for_all false
    is_filter true
    sequence(:position){ |n| n }
    searchable false
    default_value "0"
    editable true
    visible true
    multiple false
    #format_store {"url_pattern" => ""}
    description ""
    association :custom_table, factory: :custom_table
    parent_table_id nil
  end

  factory :user, aliases: [:author]  do
    firstname 'John'
    sequence(:lastname) {|n| 'Doe' + n.to_s }
    login { "#{firstname}-#{lastname}".downcase }
    sequence(:mail) {|n| "user#{n}@test.com" }
    admin false
    language 'en'
    status 1
    mail_notification 'only_my_events'

    trait :admin do
      firstname 'Admin'
      admin true
    end

    factory :admin_user, :traits => [:admin]
  end

  factory :member  do
    user_id User.current.id
    association :project, factory: :project
  end
end
