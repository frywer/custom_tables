module CustomTables
  module Patches
    module Lib
      module IssuePdfHelperPatch
        def self.included(base)
          base.class_eval do

            def pdf_format_text(object, attribute)
              text = textilizable(object, attribute,
                           :only_path => false,
                           :edit_section_links => false,
                           :headings => false,
                           :inline_attachments => false
              )
              if object.is_a?(Issue) && attribute == :description
                return text.to_s + textilizable(custom_tables_html(object).join)
              end
              return text
            end

            def custom_tables_html(issue)
              custom_tables = []
              issue.project.all_issue_custom_tables(issue).each do |custom_table|
                query = custom_table.query(totalable_all: true)
                query.add_short_filter('issue_id', "=#{issue.id}")
                result_scope = query.results_scope
                next if result_scope.empty?
                html_table = '<hr/><strong>' + custom_table.name + '</strong><br>'
                html_table += '<table><tr>'

                html_table += query.columns.map {|column| "<td><strong>" + column.custom_field.name + "</strong></td>"}.join
                html_table += "</tr>"
                result_scope.each do |custom_entity|
                  html_table += "<tr>"
                  custom_field_values = custom_entity.visible_custom_field_values
                  custom_field_values.each do |value|
                    text = show_value(value, false)
                    next if text.blank?
                    html_table += "<td>" + text + "</td>"
                  end
                  html_table += "</tr>"
                end
                html_table += "</table>"

                custom_tables << html_table
              end
              return custom_tables
            end
          end
        end
      end
    end
  end
end

Redmine::Export::PDF::IssuesPdfHelper.send(:include, CustomTables::Patches::Lib::IssuePdfHelperPatch)