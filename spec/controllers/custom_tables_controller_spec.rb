require "spec_helper"

describe CustomTablesController, logged: true do
  render_views

  include_context 'logged as admin'

  let(:custom_table) { FactoryBot.create(:custom_table, custom_fields: [
    { external_name: 'name', field_format: 'string', is_required: true },
    { external_name: 'age', field_format: 'int' },
    { field_format: 'float' }
  ] ) }

  let!(:custom_entity) { FactoryBot.create(:custom_entity, custom_table: custom_table, external_values: {
    'name' => 'Bob',
    'age'  => '24'
  } ) }

  describe '#index' do
    it 'return success response' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe '#show' do
    it 'return success response' do
      get :show, params: { id: custom_table }
      expect(response).to have_http_status(:success)
    end

    it 'returns json' do
      get :show, params: { id: custom_table, format: 'json' }
      expect(response).to have_http_status(:success)
    end
  end

  describe '#new' do
    it 'return success response' do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe '#create' do
    it 'create new entity' do
      expect {
        post :create, params: { custom_table: { name: 'Contacts'} }
      }.to change { CustomTable.count }.by(1)
    end
  end

  describe '#edit' do
    it 'return success response' do
      get :edit, params: { id: custom_table }
      expect(response).to have_http_status(:success)
    end
  end

  describe '#update' do
    it 'updates entity' do
      expect {
        put :update, params: { id: custom_table.id, custom_table: { name: 'Contacts updated'} }
      }.to change { custom_table.reload.name }
    end
  end

  describe '#destroy' do
    it 'destroy entity' do
      custom_table
      expect {
        delete :destroy, params: { id: custom_table.id }
      }.to change { CustomTable.count }
    end
  end
end