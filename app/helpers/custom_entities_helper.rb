module CustomEntitiesHelper

  def render_custom_entity_notes(journal, options={})
    content = ''
    links = []
    content << content_tag('div', links.join(' ').html_safe, class: 'contextual') unless links.empty?
    content << textilizable(journal, :notes)
    css_classes = "wiki"
    css_classes << " editable"
    content_tag('div', content.html_safe, :id => "journal-#{journal.id}-notes", class: css_classes)
  end

  def render_api_custom_entity(custom_entity, api)
    return if custom_entity.custom_values.empty?

      custom_entity.custom_values.each do |custom_value|
        api.__send__(custom_value.custom_field.external_name, custom_value.value)
      end

  end
end
