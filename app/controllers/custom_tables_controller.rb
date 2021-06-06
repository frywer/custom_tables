class CustomTablesController < ApplicationController
  layout 'admin'
  self.main_menu = false

  helper :sort
  include SortHelper
  helper :custom_fields
  helper :queries
  include QueriesHelper
  helper :issues
  helper :context_menus
  helper :custom_entities
  helper :settings
  helper :custom_tables_pdf

  before_action :find_custom_table, only: [:edit, :update, :show, :destroy, :setting_tabs]
  before_action :authorize_global
  before_action :find_custom_tables, only: [:context_menu]
  before_action :setting_tabs, only: :edit
  before_action :export_custom_entities, only: :show

  accept_api_auth :show, :index, :create, :update, :destroy

  def index
    retrieve_query(CustomTableQuery, false)

    case params[:format]
    when 'xml', 'json'
      @offset, @limit = api_offset_and_limit
    else
      @limit = per_page_option
    end

    scope = CustomTable
    scope = scope.like(params[:name_like]) if params[:name_like].present?
    @custom_tables = scope.order(@query.sort_clause)
    @custom_tables_count = scope.count
    @custom_tables_pages = Paginator.new @custom_tables_count, @limit, params['page']
    @offset ||= @custom_tables_pages.offset

    respond_to do |format|
      format.html
      format.api
    end
  end

  def show
    @query = @custom_table.query
    @query.build_from_params(params.except(:id))
    @query.sort_criteria ||= 'created_at:desc'
    sort_init @query.sort_criteria.presence || [['spent_on', 'desc']]
    sort_update(@query.sortable_columns)
    scope = @query.results_scope(order: sort_clause, pattern: params[:name_like])

    @entity_count = scope.count
    per_page = params[:per_page] == 'all' ? nil : per_page_option
    @entity_pages = Paginator.new @entity_count, per_page, params['page']
    @custom_entities ||= scope.offset(@entity_pages.offset).limit(@entity_pages.per_page).to_a
    respond_to do |format|
      format.html {}
      format.api {}
      format.pdf {
        send_file_headers! type: 'application/pdf', filename: "#{@custom_table.name}.pdf"
      }
      format.csv {
        send_data(query_to_csv(@custom_entities , @query, params[:csv]), :type => 'text/csv; header=present', filename: "#{@custom_table.name}.csv")
      }
      call_hook(:controller_custom_tables_show_format, { custom_entities: @custom_entities, custom_table: @custom_table, format: format, params: params })
    end
  end

  def new
    @custom_table = CustomTable.new

    respond_to do |format|
      format.js
      format.html
    end
  end

  def create
    @custom_table = CustomTable.new(author: User.current)
    @custom_table.safe_attributes = params[:custom_table]
    if @custom_table.save
      flash[:notice] = l(:notice_successful_create)
      respond_to do |format|
        format.html { redirect_back_or_default custom_table_path(@custom_table) }
        format.js
        format.api  { render action: 'show', status: :created, location: custom_table_url(@custom_table) }
      end
    else
      respond_to do |format|
        format.js { render action: 'new' }
        format.html { render action: 'new' }
        format.api  { render_validation_errors(@custom_table) }
      end
    end
  end

  def edit
    @custom_fields_by_type = @custom_table.custom_fields.group_by {|f| f.class.name }
    @tab = @custom_table.name
    respond_to do |format|
      format.js
      format.html
    end
  end

  def update
    @custom_table.safe_attributes = params[:custom_table]
    if @custom_table.save
      flash[:notice] = l(:notice_successful_update)
      respond_to do |format|
        format.html { redirect_back_or_default edit_custom_table_path(@custom_table) }
        format.js
        format.api  { render action: 'show', status: :updated, location: custom_table_url(@custom_table) }
      end
    else
      respond_to do |format|
        format.js { render action: 'edit'}
        format.html { render action: 'edit'}
        format.api  { render_validation_errors(@custom_table) }
      end
    end
  end

  def destroy
    @custom_table.destroy
    flash[:notice] = l(:notice_successful_delete)
    respond_to do |format|
      format.html { redirect_back_or_default custom_tables_path }
      format.js
      format.api { render_api_ok }
    end
  end

  def context_menu
    if (@custom_tables.size == 1)
      @custom_table = @custom_tables.first
    end
    @custom_tables_ids = @custom_tables.map(&:id).sort

    can_edit = @custom_tables.detect{|c| !c.editable?}.nil?
    can_delete = @custom_tables.detect{|c| !c.deletable?}.nil?
    @can = {:edit => can_edit, :delete => can_delete}
    @back = back_url

    @safe_attributes = @custom_tables.map(&:safe_attribute_names).reduce(:&)

    render layout: false
  end

  def setting_tabs
    @setting_tabs = [
      {name: 'general', partial: 'custom_tables/edit', label: :label_general},
      {name: 'custom_fields', partial: 'custom_tables/settings/custom_fields', label: :label_custom_field_plural}
    ]
    call_hook(:controller_setting_tabs_after, { setting_tabs: @setting_tabs, custom_table: @custom_table })
  end

  private

  def find_custom_table
    @custom_table = CustomTable.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_custom_tables
    @custom_tables = CustomTable.where(id: (params[:id] || params[:ids]))
  end

  def export_custom_entities
    @custom_entities = CustomEntity.where(id: params[:ids]) if params[:ids]
  end

end
