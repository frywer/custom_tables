class CustomTableQuery < Query

  self.queried_class = CustomTable

  self.available_columns = [
    QueryColumn.new(:name, sortable: "#{CustomTable.table_name}.name", caption: l(:field_name)),
    QueryColumn.new(:created_at, sortable: "#{CustomTable.table_name}.created_at", caption: l(:field_created_on))
  ]

  def initialize_available_filters
    add_available_filter "name", type: :string, label: :field_name
    add_available_filter "created_at", type: :date_past, label: :field_created_on
  end

  def initialize(attributes=nil, *args)
    super attributes
    self.filters ||= {}
    add_filter('spent_on', '*') unless filters.present?
  end

  def available_columns
    return @available_columns if @available_columns
    @available_columns = self.class.available_columns.dup
  end

  def default_columns_names
    @default_columns_names ||= begin
      default_columns = [:name, :created_at]

      project.present? ? default_columns : [:project] | default_columns
    end
  end

end