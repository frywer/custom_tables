Redmine::Plugin.register :custom_tables do
  name 'Custom Tables plugin'
  author 'Ivan Marangoz'
  description 'This is a plugin for Redmine'
  version '1.0.7'
  requires_redmine :version_or_higher => '3.4.0'
  url 'https://github.com/frywer/custom_tables'
  author_url 'https://github.com/frywer'

  permission :manage_custom_tables, {
      custom_entities: [:new, :edit, :create, :update, :destroy, :context_menu, :bulk_edit, :bulk_update],
  }, global: true

  permission :view_custom_tables, {
    custom_entities: [:show],
  }, global: true

  Redmine::FieldFormat::UserFormat.customized_class_names << 'CustomEntity'
end

Redmine::MenuManager.map :admin_menu do |menu|
  menu.push :custom_tables, :custom_tables_path, caption: :label_custom_tables,
            :html => {:class => 'icon icon-package'}
end

Dir[File.join(File.dirname(__FILE__), '/lib/custom_tables/**/*.rb')].each { |file| require_dependency file }
