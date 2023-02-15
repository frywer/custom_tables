class CustomEntityQuery < Query
  self.queried_class = CustomEntity
  self.view_permission = :show_tables

  attr_accessor :custom_table_id

  def available_columns
    return @available_columns if @available_columns
    @available_columns = [
        QueryColumn.new(:created_at, sortable: "#{CustomEntity.table_name}.created_at", caption: l(:field_created_on), groupable: true),
        QueryColumn.new(:updated_at, sortable: "#{CustomEntity.table_name}.updated_at", caption: l(:field_updated_on), groupable: true),
        QueryColumn.new(:author, sortable: lambda {User.fields_for_order_statement("authors")}, groupable: true),
        QueryColumn.new(:issue, :sortable => "#{Issue.table_name}.id"),
    ]

    @available_columns += CustomTable.find(custom_table_id).custom_fields.
      map {|cf| QueryCustomFieldColumn.new(cf) }
  end

  def initialize(attributes=nil, *args)
    super attributes
    self.filters ||= {}
    add_filter('spent_on', '*') unless filters.present?
  end

  def initialize_available_filters
    add_available_filter("issue_id", :type => :tree, :label => :label_issue)
    add_available_filter "created_at", type: :date, label: :field_created_on
    add_available_filter "updated_at", type: :date, label: :field_updated_on
    add_available_filter "author_id", type: :list, values: lambda { author_values }

    CustomEntityCustomField.visible.where(is_filter: true, custom_table_id: custom_table_id).sorted.each do |field|
      add_custom_field_filter(field)
    end
  end

  def base_scope
    CustomEntity
      .where(statement)
  end

  def results_scope(options={})
    order_option = [group_by_sort_order, (options[:order] || sort_clause)].flatten.reject(&:blank?)

    if options[:entity_ids]
      base_scope
        .where(id: options[:entity_ids])
        .order(order_option)
        .joins(joins_for_order_statement(order_option.join(',')))
    else
      if options[:pattern].present?
        base_scope
          .joins(:custom_values)
          .where(custom_table_id: custom_table_id)
          .where('LOWER(custom_values.value) LIKE LOWER(:p)', p: "%#{options[:pattern]}%")
          .distinct
          .limit(options[:limit])
          .order(order_option)
          .joins(joins_for_order_statement(order_option.join(',')))
      else
        base_scope
            .where(custom_table_id: custom_table_id)
            .limit(options[:limit])
            .order(order_option)
            .joins(joins_for_order_statement(order_option.join(',')))
      end
    end
  end

  def sql_for_issue_id_field(_field, operator, value)
    case operator
    when "="
      "#{CustomEntity.table_name}.issue_id = #{value.first.to_i}"
    when "~"
      issue = Issue.where(id: value.first.to_i).first
      if issue && (issue_ids = issue.self_and_descendants.pluck(:id)).any?
        "#{CustomEntity.table_name}.issue_id IN (#{issue_ids.join(',')})"
      else
        "1=0"
      end
    when "!*"
      "#{CustomEntity.table_name}.issue_id IS NULL"
    when "*"
      "#{CustomEntity.table_name}.issue_id IS NOT NULL"
    end
  end
end