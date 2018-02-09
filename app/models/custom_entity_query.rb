class CustomEntityQuery < Query

  self.queried_class = CustomEntity
  self.view_permission = :show_tables

  self.available_columns = [
    QueryColumn.new(:id, sortable: "#{CustomEntity.table_name}.id", caption: l(:label_id)),
    QueryColumn.new(:created_at, sortable: "#{CustomEntity.table_name}.created_at", caption: l(:field_created_on), groupable: true),
    QueryColumn.new(:updated_at, sortable: "#{CustomEntity.table_name}.updated_at", caption: l(:field_updated_on), groupable: true),
    QueryColumn.new(:author, sortable: lambda {User.fields_for_order_statement("authors")}, groupable: true)
  ]

  def available_columns
    return @available_columns if @available_columns
    @available_columns = self.class.available_columns.dup

    @available_columns += CustomTable.find(self.class.custom_table_id).custom_fields.
      map {|cf| QueryCustomFieldColumn.new(cf) }
  end

  def initialize(attributes=nil, *args)
    super attributes
    self.filters ||= {}
    add_filter('spent_on', '*') unless filters.present?
  end

  def initialize_available_filters
    add_available_filter "id", type: :integer, label: :label_id
    add_available_filter "created_at", type: :date, label: :field_created_on
    add_available_filter "updated_at", type: :date, label: :field_updated_on
    add_available_filter "author_id", type: :list, values: lambda { author_values }

    CustomEntityCustomField.visible.where(is_filter: true, custom_table_id: self.class.custom_table_id).sorted.each do |field|
      add_custom_field_filter(field)
    end
  end

  def base_scope
    CustomEntity
      .joins(:project)
      .where(statement)
  end

  def self.build_from_params(params)

    if params[:query_id]
      CustomEntityQuery.find params[:query_id]
    else
      self.custom_table_id = params[:custom_table_id]
      query = new(name: '_')
      query.build_from_params(params.except(:id))
    end
  end

  def self.custom_table_id=(id)
    @custom_table_id = id
  end

  def self.custom_table_id
    @custom_table_id
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
          .where(custom_table_id: self.class.custom_table_id)
          .where('LOWER(custom_values.value) LIKE LOWER(:p)', p: "%#{options[:pattern]}%")
          .uniq
          .limit(options[:limit])
          .order(order_option)
          .joins(joins_for_order_statement(order_option.join(',')))
      else
        base_scope
          .where(custom_table_id: self.class.custom_table_id)
          .limit(options[:limit])
          .order(order_option)
          .joins(joins_for_order_statement(order_option.join(',')))
      end
    end
  end

  def editable_by?(user)
    return false unless user
    # Admin can edit them all and regular users can edit their private queries
    # return true if user.admin? || (is_private? && self.user_id == user.id)
    # # Members can not edit public queries that are for all project (only admin is allowed to)
    # is_public? && !@is_for_all && user.allowed_to?(:manage_public_queries, project)
    true
  end

end