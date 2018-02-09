class CustomTablesController < ApplicationController
  unloadable

  helper :sort
  include SortHelper
  include TimelogHelper
  helper :custom_fields
  include CustomFieldsHelper
  helper :queries
  include QueriesHelper
  helper :issues
  helper :context_menus
  helper :custom_entities
  helper :settings
  helper :custom_tables_pdf
  include SettingsHelper

  accept_api_auth :show, :index

  before_action :find_custom_table, only: [:edit, :update, :show, :destroy, :setting_tabs]
  before_action :find_project_by_project_id, only: [:index, :new, :create, :destroy, :show, :edit, :update]
  before_action :authorize_global
  before_action :find_custom_tables, only: [:context_menu]
  before_action :setting_tabs, only: :edit
  before_action :export_custom_entities, only: :show

  def index
    retrieve_query(CustomTableQuery, false)

    scope = CustomTable.where(project_id: @project.id)
    scope = scope.like(params[:name_like]) if params[:name_like].present?
    @custom_tables = scope.order(@query.sort_clause)

    respond_to do |format|
      format.html
      format.api
    end
  end

  def show
    unless api_request?
      params[:sort] ||= 'created_at:desc'
      params[:t] ||= @custom_table.custom_fields.select(&:totalable?).map {|i| "cf_#{i.id}"}
      params[:c] ||= @custom_table.custom_fields.order(:position).map {|i| "cf_#{i.id}"}
      @query ||= CustomEntityQuery.build_from_params(params.merge(custom_table_id: params[:id]))
      sort_init @query.sort_criteria.presence || [['spent_on', 'desc']]
      sort_update(@query.sortable_columns)
      @tab = @custom_table.name
      scope = @query.results_scope(order: sort_clause, pattern: params[:name_like])

      @entity_count = scope.count
      @entity_pages = Paginator.new @entity_count, per_page_option, params['page']
      @custom_entities ||= scope.offset(@entity_pages.offset).limit(@entity_pages.per_page).to_a
    end

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
    @custom_table = CustomTable.new(project: @project, author: User.current)
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
      format.html { redirect_back_or_default project_custom_tables_path(project_id: @project) }
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

    render :layout => false
  end

  def setting_tabs
    @setting_tabs = [
      {name: 'general', partial: 'custom_tables/edit', label: :label_general}
    ]
    call_hook(:controller_setting_tabs_after, { setting_tabs: @setting_tabs, custom_table: @custom_table })
  end

  private

  def find_project_by_project_id
    @project = @custom_table.try(:project) || super
  end

  def find_custom_table
    @custom_table = CustomTable.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_custom_tables
    @custom_tables = CustomTable.where(id: (params[:id] || params[:ids]))
  end

  def authorize_global
    allowed = User.current.allowed_to?({controller: params[:controller], action: params[:action]}, @project)
    if allowed
      true
    else
      deny_access
    end
  end

  def export_custom_entities
    @custom_entities = CustomEntity.find(params[:ids]) if params[:ids]
  end

end
