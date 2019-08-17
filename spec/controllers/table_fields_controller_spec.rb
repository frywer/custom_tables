require "spec_helper"

describe TableFieldsController, logged: true do

  let(:custom_table) { FactoryBot.create(:custom_table) }
  let(:custom_field) { FactoryBot.create(:custom_field, custom_table_id: custom_table.id, name: 'old cf name') }
  let(:custom_entity) { FactoryBot.create(:custom_entity, custom_table_id: custom_table.id ) }
  let(:custom_value) { FactoryBot.create(:custom_value, customized_id: custom_entity.id, custom_field_id: custom_field.id ) }

  include_context 'logged as admin'

  it '#new' do
    get :new, params: { custom_table_id: custom_table.id }
    expect(response).to have_http_status(:success)
  end

  context '#create' do
    it 'is valid' do
      expect {
        post :create, params: { custom_field: { field_format: 'string', name: 'some name', description: 'fdsf', is_filter: '1', is_required: '0', custom_table_id: custom_table.id }, type: "CustomEntityCustomField" }
      }.to change { CustomField.count }.by(1)
    end

    it 'is invalid' do
      custom_field
      expect {
        post :create, params: { custom_field: { field_format: 'string', name: 'old cf name', description: 'fdsf', is_filter: '1', is_required: '0', custom_table_id: custom_table.id }, type: "CustomEntityCustomField", back_url: new_table_field_path }
      }.to change { CustomField.count }.by(0)
    end

    it 'is invalid nil name' do
      custom_entity
      expect {
        post :create, params: { custom_field: { field_format: 'string', name: '', description: 'fdsf', is_filter: '1', is_required: '0', custom_table_id: custom_table.id }, type: "CustomEntityCustomField", back_url: new_table_field_path }
      }.to change { CustomField.count }.by(0)
    end
  end

  it '#edit' do
    get :edit, params: { id: custom_field }
    expect(response).to have_http_status(:success)
  end

  context '#update' do
    let(:custom_field_1) { FactoryBot.create(:custom_field, custom_table_id: custom_table.id, name: 'cf_1') }

    it 'is valid' do
      expect {
        put :update, params: { id: custom_field, custom_field: { name: 'BlaCF'} }
      }.to change {custom_field.reload.name}
    end
  end

  it '#delete' do
    custom_value
    expect {delete :destroy, params: { id: custom_field.id }}.to change(CustomField, :count).by(-1)
  end

end