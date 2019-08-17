require "spec_helper"

describe CustomTablesController, logged: true do

  include_context 'logged as admin'

  let(:custom_table) { FactoryBot.create(:custom_table) }

  it '#index' do
    get :index
    expect(response).to have_http_status(:success)
  end

  it '#show' do
    get :show, params: { id: custom_table }
    expect(response).to have_http_status(:success)
  end

  it '#new' do
    get :new
    expect(response).to have_http_status(:success)
  end

  it '#create' do
    expect {
      post :create, params: { custom_table: { name: 'Contacts'} }
    }.to change { CustomTable.count }.by(1)
  end

  it '#edit' do
    get :edit, params: { id: custom_table }
    expect(response).to have_http_status(:success)
  end

  it '#update' do
    expect {
      put :update, params: { id: custom_table.id, custom_table: { name: 'Contacts updated'} }
    }.to change { custom_table.reload.name }
  end

  it '#destroy' do
    custom_table
    expect {
      delete :destroy, params: { id: custom_table.id }
    }.to change { CustomTable.count }
  end

end