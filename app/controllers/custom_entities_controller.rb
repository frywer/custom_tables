class CustomEntitiesController < ApplicationController
  unloadable

  helper :issues
  include TimelogHelper
  helper :journals
  helper :custom_tables
  helper :context_menus
  helper :custom_fields
  helper :queries
  include QueriesHelper
  helper :sort
  include SortHelper
  helper :custom_tables_pdf

  accept_api_auth :show

  before_filter :authorize_global
  before_filter :find_custom_entity, only: [:show, :edit, :update, :add_belongs_to, :new_note]
  before_filter :find_custom_entities, only: [:context_menu, :bulk_edit, :bulk_update, :destroy, :context_export]
  before_filter :find_project_by_project_id, only: [:new, :show, :edit, :update]
  before_filter :find_journals, only: :show


  def index

    respond_to do |format|
      format.html
      format.api
    end
  end

  def show
    @attrs_names = @custom_entity.custom_values.map {|v| {name: v.custom_field.name.downcase.gsub(/[^0-9A-Za-z]/, '_'), value: v.value}}
    @tab = @custom_entity.custom_table.name
    @queries_scope = []
    retrieve_sub_tables_query

    respond_to do |format|
      format.js
      format.html
      format.api
      format.pdf  { send_file_headers! type: 'application/pdf', filename: "#{@custom_entity.name}.pdf" }
    end
  end

  def new
    custom_table = CustomTable.find_by(id: params[:custom_table_id])
    if (class_name = custom_table.class.name) == 'CustomTable'
      @custom_entity = CustomEntity.new
    else
      @custom_entity = "CustomEntities::#{class_name.split('::').last}".constantize.new
    end
    @custom_entity.custom_table_id = params[:custom_table_id]
    @custom_entity.custom_field_values = params[:custom_entity][:custom_field_values] if params[:custom_entity]
    @tab = @custom_entity.custom_table.name

    respond_to do |format|
      format.js
      format.html
    end
  end

  def new_note

    respond_to do |format|
      format.js
      format.html
    end
  end

  def create
    custom_table = CustomTable.find_by(id: params[:custom_entity][:custom_table_id])
    if (class_name = custom_table.class.name) == 'CustomTable'
      @custom_entity = CustomEntity.new
    else
      @custom_entity = "CustomEntities::#{class_name.split('::').last}".constantize.new
    end
    @custom_entity.attributes = { author: User.current, custom_table_id: params[:custom_entity][:custom_table_id] }
    @custom_entity.safe_attributes = params[:custom_entity]

    if params[:parent_entities_cf_ids].present?
      @custom_entity.parent_entity_ids = params[:custom_entity][:custom_field_values].select {|k, v| params[:parent_entities_cf_ids].include?(k)}.values
    end

    if @custom_entity.save
      flash[:notice] = l(:notice_successful_create)
      respond_to do |format|
        format.html { redirect_back_or_default custom_entity_path(@custom_entity) }
        format.js
        format.api  { render action: 'show', status: :created, location: custom_entity_url(@custom_entity) }
      end
    else
      respond_to do |format|
        format.js { render action: 'new' }
        format.html { render action: 'new' }
        format.api  { render_validation_errors(@custom_entity) }
      end
    end
  end

  def edit
    @tab = @custom_entity.custom_table.name
    respond_to do |format|
      format.js
      format.html
    end
  end

  def update
    @custom_entity.init_journal(User.current)
    @custom_entity.safe_attributes = params[:custom_entity]
    if params[:parent_entities_cf_ids].present?
      @custom_entity.parent_entity_ids = params[:custom_entity][:custom_field_values].select {|k, v| params[:parent_entities_cf_ids].include?(k)}.values
    end

    if @custom_entity.save
      flash[:notice] = l(:notice_successful_update)
      respond_to do |format|
        format.html { redirect_back_or_default custom_entity_path(@custom_entity) }
        format.js
        format.api  { render action: 'show', status: :created, location: custom_entity_url(@custom_entity) }
      end
    else
      respond_to do |format|
        format.js { render action: 'edit' }
        format.html { render action: 'edit' }
        format.api  { render_validation_errors(@custom_entity) }
      end
    end
  end

  def destroy
    custom_table = @custom_entities.first.custom_table
    @custom_entities.destroy_all

    respond_to do |format|
      format.html {
        flash[:notice] = l(:notice_successful_delete)
        redirect_back_or_default project_custom_table_path(custom_table, project_id: custom_table.project.identifier)
      }
      format.api { render_api_ok }
    end
  end

  def add_belongs_to
    @custom_field = CustomEntityCustomField.find(params[:custom_field_id])
    @tab = @custom_entity.custom_table.name
    respond_to do |format|
      format.js
      format.html
    end
  end

  def context_menu
    if (@custom_entities.size == 1)
      @custom_entity = @custom_entities.first
    end
    @custom_entity_ids = @custom_entities.map(&:id).sort

    can_edit = @custom_entities.detect{|c| !c.editable?}.nil?
    can_delete = @custom_entities.detect{|c| !c.deletable?}.nil?
    @can = {:edit => can_edit, :delete => can_delete}
    @back = back_url

    @safe_attributes = @custom_entities.map(&:safe_attribute_names).reduce(:&)

    render :layout => false
  end

  def bulk_edit
    @custom_fields = @custom_entities.map { |c| c.available_custom_fields }.reduce(:&).uniq
  end

  def bulk_update
    unsaved, saved = [], []
    attributes = parse_params_for_bulk_update(params[:custom_entity])
    @custom_entities.each do |custom_entity|
      custom_entity.init_journal(User.current)
      custom_entity.safe_attributes = attributes
      if custom_entity.save
        saved << custom_entity
      else
        unsaved << custom_entity
      end
    end
    respond_to do |format|
      format.html do
        if unsaved.blank?
          flash[:notice] = l(:notice_successful_update)
        else
          flash[:error] = unsaved.map { |i| i.errors.full_messages }.flatten.uniq.join(",\n")
        end
        redirect_back_or_default custom_table_path(@custom_entities.first.custom_table)
      end
    end
  end

  def model
    CustomEntity
  end

  def context_export
    custom_table = @custom_entities.first.custom_table
    respond_to do |format|
      call_hook(:controller_custom_entities_context_export_format, { custom_entities: @custom_entities, custom_table: custom_table, format: format })
    end
  end

  private

  def retrieve_sub_tables_query
    return unless (sub_table_ids = CustomEntityCustomField.where(parent_table_id: @custom_entity.custom_table_id).uniq.pluck(:custom_table_id))
    sub_tables = CustomTable.where(id: sub_table_ids)
    sub_tables.each do |table|
      cf_selected_ids = table.custom_fields.where(parent_table_id: @custom_entity.custom_table.id).pluck(:id)
      params[:c] = table.custom_fields.map {|i| "cf_#{i.id}"}
      query = CustomEntityQuery.build_from_params(params.merge(custom_table_id: table.id))
      sort_init query.sort_criteria.presence || [['spent_on', 'desc']]
      sort_update(query.sortable_columns)

      @queries_scope << {
        name: table.name,
        query: query,
        custom_entities: query.results_scope(order: sort_clause, entity_ids: (@custom_entity.sub_entities & table.custom_entities).map(&:id)),
        custom_table_id: table.id,
        selected_custom_values: cf_selected_ids.collect {|a| {a.to_s => @custom_entity.id.to_s}}.inject(:merge)
      }
    end
  end

  def find_journals
    @journals = @custom_entity.journals.preload(:journalized, :user, :details).reorder("#{Journal.table_name}.id ASC").to_a
    @journals.each_with_index { |j, i| j.indice = i+1 }
    Journal.preload_journals_details_custom_fields(@journals)
    @journals.reverse!
  end

  def find_custom_entity
    @custom_entity = CustomEntity.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_custom_entities
    @custom_entities = CustomEntity.where(id: (params[:id] || params[:ids]))
  end

  def find_project_by_project_id
    @project = @custom_entity.try(:project) || super
  end

end
