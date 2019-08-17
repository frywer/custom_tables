module CustomTables
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_issues_show_description_bottom, partial: 'issues/custom_tables'
  end
end