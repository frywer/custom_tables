module CustomTablesPdfHelper

  # Returns a PDF string of a list of custom tables
  def custom_tables_to_pdf(custom_tables, project, query)
    pdf = Redmine::Export::PDF::ITCPDF.new(current_language, "L")
    title = custom_tables.first.name
    title = "#{project} - #{title}" if project
    pdf.set_title(title)
    pdf.alias_nb_pages
    pdf.footer_date = format_date(User.current.today)
    pdf.set_auto_page_break(false)
    pdf.add_page("L")

    # Landscape A4 = 210 x 297 mm
    page_height   = pdf.get_page_height # 210
    page_width    = pdf.get_page_width  # 297
    left_margin   = pdf.get_original_margins['left'] # 10
    right_margin  = pdf.get_original_margins['right'] # 10
    bottom_margin = pdf.get_footer_margin
    row_height    = 4

    # column widths
    table_width = page_width - right_margin - left_margin
    col_width = []
    unless query.inline_columns.empty?
      col_width = calc_col_width(custom_tables, query, table_width, pdf)
      table_width = col_width.inject(0, :+)
    end

    # title
    pdf.SetFontStyle('B',11)
    pdf.RDMCell(190, 8, title)
    pdf.ln

    # totals
    totals = query.totals.map {|column, total| "#{column.caption}: #{total}"}
    if totals.present?
      pdf.SetFontStyle('B',10)
      pdf.RDMCell(table_width, 6, totals.join("  "), 0, 1, 'R')
    end

    totals_by_group = query.totals_by_group
    render_table_header(pdf, query, col_width, row_height, table_width)
    previous_group = false
    issue_list(custom_tables) do |issue, level|
      if query.grouped? &&
          (group = query.group_by_column.value(issue)) != previous_group
        pdf.SetFontStyle('B',10)
        group_label = group.blank? ? 'None' : group.to_s.dup
        group_label << " (#{query.result_count_by_group[group]})"
        pdf.bookmark group_label, 0, -1
        pdf.RDMCell(table_width, row_height * 2, group_label, 'LR', 1, 'L')
        pdf.SetFontStyle('',8)

        totals = totals_by_group.map {|column, total| "#{column.caption}: #{total[group]}"}.join("  ")
        if totals.present?
          pdf.RDMCell(table_width, row_height, totals, 'LR', 1, 'L')
        end
        previous_group = group
      end

      # fetch row values
      col_values = fetch_row_values(issue, query, level)

      # make new page if it doesn't fit on the current one
      base_y     = pdf.get_y
      max_height = get_issues_to_pdf_write_cells(pdf, col_values, col_width)
      space_left = page_height - base_y - bottom_margin
      if max_height > space_left
        pdf.add_page("L")
        render_table_header(pdf, query, col_width, row_height, table_width)
        base_y = pdf.get_y
      end

      # write the cells on page
      issues_to_pdf_write_cells(pdf, col_values, col_width, max_height)
      pdf.set_y(base_y + max_height)

    end

    pdf.output
  end

  def custom_entity_to_pdf(custom_entity, assoc={})
    pdf = Redmine::Export::PDF::ITCPDF.new(current_language)
    pdf.alias_nb_pages
    pdf.footer_date = format_date(User.current.today)
    pdf.add_page
    pdf.SetFontStyle('B',11)
    pdf.SetFontStyle('',8)
    base_x = pdf.get_x
    i = 1
    pdf.SetFontStyle('B',11)
    pdf.RDMMultiCell(190 - i, 5, "#{custom_entity.custom_table.name} - #{custom_entity.name}")
    pdf.SetFontStyle('',8)
    pdf.RDMMultiCell(190, 5, "#{format_time(custom_entity.created_at)} - #{custom_entity.author}")
    pdf.ln

    left = []

    right = []

    left_side = true
    attr = custom_entity.custom_values.map {|v| {name: v.custom_field.name, value: v.value}}
    attr.each do |att|
      if left_side
        left << [att[:name], att[:value]]
        left_side = false
      else
        right << [att[:name], att[:value]]
        left_side = true
      end
    end

    rows = left.size > right.size ? left.size : right.size
    while left.size < rows
      left << nil
    end
    while right.size < rows
      right << nil
    end

    if pdf.get_rtl
      border_first_top = 'RT'
      border_last_top  = 'LT'
      border_first = 'R'
      border_last  = 'L'
    else
      border_first_top = 'LT'
      border_last_top  = 'RT'
      border_first = 'L'
      border_last  = 'R'
    end

    rows = left.size > right.size ? left.size : right.size
    rows.times do |i|
      heights = []
      pdf.SetFontStyle('B',9)
      item = left[i]
      heights << pdf.get_string_height(35, item ? "#{item.first}:" : "")
      item = right[i]
      heights << pdf.get_string_height(35, item ? "#{item.first}:" : "")
      pdf.SetFontStyle('',9)
      item = left[i]
      heights << pdf.get_string_height(60, item ? item.last.to_s  : "")
      item = right[i]
      heights << pdf.get_string_height(60, item ? item.last.to_s  : "")
      height = heights.max

      item = left[i]
      pdf.SetFontStyle('B',9)
      pdf.RDMMultiCell(35, height, item ? "#{item.first}:" : "", (i == 0 ? border_first_top : border_first), '', 0, 0)
      pdf.SetFontStyle('',9)
      pdf.RDMMultiCell(60, height, item ? item.last.to_s : "", (i == 0 ? border_last_top : border_last), '', 0, 0)

      item = right[i]
      pdf.SetFontStyle('B',9)
      pdf.RDMMultiCell(35, height, item ? "#{item.first}:" : "",  (i == 0 ? border_first_top : border_first), '', 0, 0)
      pdf.SetFontStyle('',9)
      pdf.RDMMultiCell(60, height, item ? item.last.to_s : "", (i == 0 ? border_last_top : border_last), '', 0, 2)

      pdf.set_x(base_x)
    end

    pdf.RDMCell(190,5, "", "T")
    pdf.ln
    pdf.output
  end

end
