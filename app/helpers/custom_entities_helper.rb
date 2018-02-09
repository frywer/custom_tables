module CustomEntitiesHelper

  def render_custom_entity_notes(journal, options={})
    content = ''
    links = []
    if journal.notes.present?
      links << link_to(l(:button_edit),
                       edit_note_journal_path(journal),
                       remote: true,
                       title: l(:button_edit),
                       class: 'icon-only icon-edit')

      links << link_to(l(:button_delete),
                       journal_path(journal, notes: ""),
                       remote: true,
                       method: 'put',
                       data: {confirm: l(:text_are_you_sure)},
                       title: l(:button_delete),
                       class: 'icon-only icon-del')
    end
    content << content_tag('div', links.join(' ').html_safe, class: 'contextual') unless links.empty?
    content << textilizable(journal, :notes)
    css_classes = "wiki"
    css_classes << " editable"
    content_tag('div', content.html_safe, :id => "journal-#{journal.id}-notes", class: css_classes)
  end

  def render_api_custom_entity(custom_entity, api)
    return if custom_entity.custom_values.empty?
    #attrs = custom_entity.custom_values.map {|v| {name: v.custom_field.name.downcase.gsub(/[^0-9A-Za-z]/, '_'), value: v.value}}

      custom_entity.custom_values.each do |custom_value|
        api.__send__(custom_value.custom_field.external_name, custom_value.value)
      end

  end


end
