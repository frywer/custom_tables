require "spec_helper"

describe TableFieldsController, logged: true do

  let(:project) { FactoryGirl.create(:project) }
  let(:custom_table) { FactoryGirl.create(:custom_table) }
  let(:custom_field) { FactoryGirl.create(:custom_field, custom_table_id: custom_table.id, name: 'old cf name') }
  let(:custom_entity) { FactoryGirl.create(:custom_entity, custom_table_id: custom_table.id ) }
  let(:custom_value) { FactoryGirl.create(:custom_value, customized_id: custom_entity.id, custom_field_id: custom_field.id ) }

  render_views

  before(:each) do
    role = Role.non_member
    role.add_permission! :show_tables
    role.add_permission! :manage_tables
    role.add_permission! :delete_tables
  end

  it 'get new' do
    get :new, custom_table_id: custom_table.id, project_id: project.identifier
    #expect(response).to render_template('table_fields/new')
    expect(response).to have_http_status(:success)

    Role.non_member.remove_permission! :manage_tables
    User.current.reload
    get :new, custom_table_id: custom_table.id
    expect(response).to have_http_status(403)
  end

  context 'create' do

    it 'valid' do
      expect {
        post :create, custom_field: { field_format: 'string', name: 'some name', description: 'fdsf', is_filter: '1', is_required: '0', custom_table_id: custom_table.id }, type: "CustomEntityCustomField"
      }.to change { CustomField.count }.by(1)
      expect(response).to redirect_to(edit_custom_table_path(custom_table))

      Role.non_member.remove_permission! :manage_tables
      User.current.reload
      post :create, custom_field: { field_format: 'string', name: 'some name', description: 'fdsf', is_filter: '1', is_required: '0', custom_table_id: custom_table.id }, type: "CustomEntityCustomField"
      expect(response).to have_http_status(403)
    end

    it 'invalid same name ' do
      custom_field
      expect {
        post :create, custom_field: { field_format: 'string', name: 'old cf name', description: 'fdsf', is_filter: '1', is_required: '0', custom_table_id: custom_table.id }, type: "CustomEntityCustomField", back_url: new_table_field_path
      }.to change { CustomField.count }.by(0)
      expect(response).to render_template('table_fields/new')
    end

    it 'invalid nil name' do
      custom_entity
      expect {
        post :create, custom_field: { field_format: 'string', name: '', description: 'fdsf', is_filter: '1', is_required: '0', custom_table_id: custom_table.id }, type: "CustomEntityCustomField", back_url: new_table_field_path
      }.to change { CustomField.count }.by(0)
      expect(response).to render_template('table_fields/new')
    end

  end

  it 'get edit' do
    get :edit, id: custom_field
    expect(response).to have_http_status(:success)
    expect(response).to render_template('table_fields/edit')

    Role.non_member.remove_permission! :manage_tables
    User.current.reload
    get :edit, id: custom_field
    expect(response).to have_http_status(403)
  end

  context 'update' do
    let(:custom_field_1) { FactoryGirl.create(:custom_field, custom_table_id: custom_table.id, name: 'cf_1') }

    it 'valid' do
      put :update, id: custom_field, custom_field: { name: 'BlaCF'}, back_url: edit_custom_table_path(custom_field.custom_table)
      custom_field.reload
      expect(custom_field.name).to eq('BlaCF')
      expect(response).to redirect_to(edit_custom_table_path(custom_field.custom_table))


      Role.non_member.remove_permission! :manage_tables
      User.current.reload
      put :update, id: custom_field, custom_field: { name: 'BlaCF'}, back_url: edit_custom_table_path(custom_field.custom_table)
      expect(response).to have_http_status(403)
    end

    it 'invalid same name' do
      put :update, id: custom_field, custom_field: { name: 'cf_1'}, back_url: edit_custom_table_path(custom_field.custom_table)
      custom_field.reload
      expect(response).to redirect_to(edit_custom_table_path(custom_field.custom_table))
    end
  end

  it 'delete' do
    custom_value
    table = custom_field.custom_table
    cf_id = custom_field.id
    expect(CustomValue.where(custom_field_id: cf_id).count).to eq 1
    expect {delete :destroy, id: custom_field.id}.to change(CustomField, :count).by(-1)
    expect(CustomValue.where(custom_field_id: cf_id).count).to eq 0
    expect(response).to redirect_to(edit_custom_table_path(table))
  end

  context 'belongs to custom field' do
    let(:sub_entity) { FactoryGirl.create(:custom_entity, custom_table_id: custom_table.id, parent_entity_ids: custom_entity.id ) }
    let(:belongs_to_field) { FactoryGirl.create(:custom_field, custom_table_id: custom_table.id, field_format: 'belongs_to') }
    let(:custom_value) { FactoryGirl.create(:custom_value, customized_id: sub_entity.id, custom_field_id: belongs_to_field.id, value: custom_entity.id.to_s) }

    it 'destroy field' do
      custom_value
      expect(custom_entity.sub_entities.include?(sub_entity)).to be true
      expect {delete :destroy, id: belongs_to_field.id}.to change(CustomField, :count).by(-1)
      custom_entity.reload
      expect(custom_entity.sub_entities.include?(sub_entity)).to be false
    end
  end

end