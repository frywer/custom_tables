class CustomEntitiesController < ApplicationController
  layout 'admin'
  self.main_menu = false

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

  before_action :authorize_global
  before_action :find_custom_entity, only: [:show, :edit, :update, :add_belongs_to, :new_note]
  before_action :find_custom_entities, only: [:context_menu, :bulk_edit, :bulk_update, :destroy, :context_export]
  before_action :find_journals, only: :show

  def index
    respond_to do |format|
      format.html
      format.api
    end
  end

  def show
    @queries_scope = []
    respond_to do |format|
      format.js
      format.html
      format.api
      format.pdf  { send_file_headers! type: 'application/pdf', filename: "#{@custom_entity.name}.pdf" }
    end
  end

  def new
    @custom_entity = CustomEntity.new
    @custom_entity.custom_table_id = params[:custom_table_id]
    @custom_entity.custom_field_values = params[:custom_entity][:custom_field_values] if params[:custom_entity]

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
    @custom_entity = CustomEntity.new(author: User.current, custom_table_id: params[:custom_entity][:custom_table_id])
    @custom_entity.safe_attributes = params[:custom_entity]

    if @custom_entity.save
      flash[:notice] = l(:notice_successful_create)
      respond_to do |format|
        format.html { redirect_back_or_default custom_table_path(@custom_entity.custom_table) }
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

    if @custom_entity.save
      flash[:notice] = l(:notice_successful_update)
      respond_to do |format|
        format.html { redirect_back_or_default custom_table_path(@custom_entity.custom_table) }
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
        redirect_back_or_default custom_table_path(custom_table)
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

  def find_journals
    @journals = @custom_entity.journals.preload(:journalized, :user, :details).reorder("#{Journal.table_name}.id ASC").to_a
    @journals.each_with_index { |j, i| j.indice = i+1 }
    Journal.preload_journals_details_custom_fields(@journals)
    @journals.reverse!
  end

  def find_custom_entity
    @custom_entity = CustomEntity.find(params[:id])
    render_403 unless @custom_entity.editable?
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_custom_entities
    @custom_entities = CustomEntity.where(id: (params[:id] || params[:ids]))
  end

end
