module CustomTablesHelper
  def custom_table_tabs(project_id = nil)
    tabs = []
    tabs << { name: 'index', show: 'custom_tables/custom_index', index: 'custom_tables/custom_index', label: 'index', table_id: nil, project_id: project_id, path: project_custom_tables_path(project_id: @project.try(:identifier) || params[:project_id]) }
    CustomTable.where(project_id: project_id).sorted.each do |table|
      tabs << { name: table.name, show: 'custom_tables/custom_table_tab', edit: 'custom_tables/edit', label: l(:label_custom_table_tab, name: table.name), table_id: table, project_id: @project.try(:identifier) || project_id }
    end
    tabs
  end

  def render_setting_tabs(tabs, selected=params[:tab], locals = {})
    if tabs.any?
      unless tabs.detect {|tab| tab[:name] == selected}
        selected = nil
      end
      selected ||= tabs.first[:name]
      render :partial => 'common/tabs', :locals => {:tabs => tabs, :selected_tab => selected}.merge(locals)
    else
      content_tag 'p', l(:label_no_data), :class => "nodata"
    end
  end

  def render_custom_table_tabs(tabs, selected = params[:tab], entity = nil)
    if tabs.any?
      unless tabs.detect {|tab| tab[:name] == selected}
        selected = nil
      end
      selected ||= tabs.first[:name]
      render partial: 'custom_tables/tabs', locals: {tabs: tabs, selected_tab: selected}
    else
      content_tag 'p', l(:label_no_data), class: "nodata"
    end
  end

  def render_custom_table_content(column, entity)
    value = column.value_object(entity)
    if value.is_a?(Array)
      value.collect {|v| send("#{entity.class.name.underscore}_column_value", column, entity, v)}.compact.join(', ').html_safe
    else
      if entity.is_a? CustomEntity
        custom_entity_column_value column, entity, value
      else
        custom_table_column_value column, entity, value
      end
    end
  end

  def custom_table_column_value(column, entity, value)
    case column.name
    when :name
      link_to value, custom_table_path(entity)
    else
      format_object(value)
    end
  end

  def custom_entity_column_value(column, custom_entity, custom_value)
    return format_object(custom_value) unless custom_value.is_a? CustomValue
    value = custom_value.value
    case column.custom_field.field_format
    when 'belongs_to'
      if value.present? && custom_value.custom_entity_id
        link_to value, custom_entity_path(custom_value.custom_entity_id)
      else
        value || '---'
      end
    when 'bool'
      if custom_value.true?
        l(:general_text_Yes)
      else
        l(:general_text_No)
      end
    when 'date'
      if value.present?
        Date.parse(value).strftime(Setting.date_format)
      else
        '---'
      end
    else
      if custom_entity.main_custom_field.id == column.custom_field.id # If main custom value
        link_to value, custom_entity_path(custom_entity)
      else
        format_object(value)
      end
    end
  end

  def render_sidebar_table_queries(table)
    queries = CustomEntityQuery.where(custom_table_id: table.id)

    out = ''.html_safe
    out << query_links(l(:label_my_queries), queries.select(&:is_private?))
    out << query_links(l(:label_query_plural), queries.reject(&:is_private?))
    out
  end
end
