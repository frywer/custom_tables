require "spec_helper"

describe CustomEntitiesController, logged: true do

  let(:custom_table) { FactoryBot.create(:custom_table) }
  let(:custom_fields) { FactoryBot.create_list(:custom_field, 3, custom_table_id: custom_table.id) }
  let(:custom_field) { FactoryBot.create(:custom_field, custom_table_id: custom_table.id) }
  let(:custom_entity) { FactoryBot.create(:custom_entity, custom_table_id: custom_table.id ) }
  let(:custom_entity_2) { FactoryBot.create(:custom_entity, custom_table_id: custom_table.id ) }
  let(:custom_value) { FactoryBot.create(:custom_value, customized_id: custom_entity.id, custom_field_id: custom_field.id ) }

  include_context 'logged as admin'

  it '#show' do
    custom_value
    get :show, params: { id: custom_entity }
    expect(response).to have_http_status(:success)
  end

  it '#new' do
    custom_value
    get :new, params: { custom_table_id: custom_table.id }
    expect(response).to have_http_status(:success)
  end

  it '#create' do
    custom_fields
    cf_values = custom_fields.inject({}) {|k, v| k[v.id.to_s] = "value#{v.name}"; k}
    expect {
      post :create, params: { custom_entity: { custom_table_id: custom_table.id, custom_field_values: cf_values } }
    }.to change { CustomEntity.count }.by(1)
  end

  it '#edit' do
    get :edit, params: { id: custom_entity }
    expect(response).to have_http_status(:success)
  end

  it '#update' do
    custom_value
    cf_values = custom_entity.custom_fields.inject({}) {|k, v| k[v.id.to_s] = "new_value"; k}

    expect {
      put :update, params: { id: custom_entity, custom_entity: { custom_field_values: cf_values } }
    }.to change { custom_entity.reload.custom_values.last.value }
  end

  it 'update notes' do
    expect {
      put :update, params: { id: custom_entity, custom_entity: { notes: 'notes' } }
    }.to change(Journal, :count)
  end

  it '#delete' do
    custom_value
    expect {delete :destroy, params: { id: custom_entity }}.to change(CustomEntity, :count).by(-1)
  end

  it '#bulk_delete' do
    custom_entity
    custom_entity_2
    expect {delete :destroy, params: { ids: [custom_entity.id, custom_entity_2.id] }}.to change(CustomEntity, :count).by(-2)
  end

end