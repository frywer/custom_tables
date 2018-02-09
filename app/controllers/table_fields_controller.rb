class TableFieldsController < CustomFieldsController
  unloadable

  layout 'base'

  helper :custom_fields
  helper :custom_tables
  helper :queries
  include QueriesHelper

  before_filter :authorize_global
  before_filter :build_new_custom_field, only: [:new, :create]
  before_filter :find_project_by_project_id, only: [:new, :update, :create, :edit]

  def new
    @custom_table = CustomTable.find(params[:custom_table_id])
    @tab = @custom_table.name
    super
  end

  def create
    if @custom_field.save
      flash[:notice] = l(:notice_successful_create)
      respond_to do |format|
        format.html do
          redirect_back_or_default edit_custom_table_path(id: @custom_field.custom_table)
        end
        format.js
      end
    else
      respond_to do |format|
        format.js { render action: 'new' }
        format.html { render action: 'new' }
      end
    end
  end

  def edit
    @tab = @custom_field.custom_table.name

    respond_to do |format|
      format.js
      format.html
    end
  end

  def update

    @custom_field.safe_attributes = params[:custom_field]
    if @custom_field.save
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_successful_update)
          redirect_back_or_default edit_custom_table_path(@custom_field.custom_table)
        }
        format.js { head 200 }
      end
    else
      respond_to do |format|
        format.html { render action: 'edit'}
        format.js { head 422 }
      end
    end
  end

  def destroy
    table = @custom_field.custom_table
    begin
      @custom_field.clean_values!
      @custom_field.destroy
    rescue
      flash[:error] = l(:error_can_not_delete_custom_field)
    end

    respond_to do |format|
      format.html {
        flash[:notice] = l(:notice_successful_delete)
        redirect_back_or_default edit_custom_table_path(id: table)
      }
      format.api { render_api_ok }
    end
  end

  private

  def build_new_custom_field
    @custom_field = CustomField.new_subclass_instance('CustomEntityCustomField', params[:custom_field])
  end

  def require_admin

  end

  def find_project_by_project_id
    @project = @custom_field.custom_table.try(:project) || super
  end

end