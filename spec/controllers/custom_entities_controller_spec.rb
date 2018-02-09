require "spec_helper"

describe CustomEntitiesController, logged: true do
  render_views

  let(:project) { FactoryGirl.create(:project) }
  let(:custom_table) { FactoryGirl.create(:custom_table, project_id: project.id) }
  let(:custom_fields) { FactoryGirl.create_list(:custom_field, 3, custom_table_id: custom_table.id) }
  let(:custom_field) { FactoryGirl.create(:custom_field, custom_table_id: custom_table.id) }
  let(:custom_entity) { FactoryGirl.create(:custom_entity, custom_table_id: custom_table.id ) }
  let(:custom_entity_2) { FactoryGirl.create(:custom_entity, custom_table_id: custom_table.id ) }
  let(:custom_value) { FactoryGirl.create(:custom_value, customized_id: custom_entity.id, custom_field_id: custom_field.id ) }

  let(:sub_custom_table) { FactoryGirl.create(:custom_table, project_id: project.id) }
  let(:sub_custom_entity) { FactoryGirl.create(:custom_entity, parent_entity_ids: custom_entity.id, custom_table_id: sub_custom_table.id ) }
  let(:sub_custom_field) { FactoryGirl.create(:custom_field, custom_table_id: sub_custom_table.id, parent_table_id: custom_table.id, field_format: "belongs_to") }
  let(:sub_custom_value) { FactoryGirl.create(:custom_value, customized_id: sub_custom_entity.id, custom_field_id: sub_custom_field.id ) }

  before(:each) do
    role = Role.non_member
    role.add_permission! :show_tables
    role.add_permission! :manage_tables
    role.add_permission! :delete_tables
  end

  it 'show' do
    sub_custom_value
    custom_value
    get :show, id: custom_entity
    expect(response).to have_http_status(:success)
    expect(response).to render_template('custom_entities/show')

    Role.non_member.remove_permission! :show_tables
    get :show, id: custom_entity
    expect(response).to have_http_status(403)
  end

  it 'get new' do
    custom_value
    get :new, custom_table_id: custom_table.id, project_id: project.identifier
    expect(response).to render_template('custom_entities/new')
    expect(response).to have_http_status(:success)

    Role.non_member.remove_permission! :manage_tables
    User.current.reload
    get :new, custom_table_id: custom_table.id
    expect(response).to have_http_status(403)
  end

  context 'create' do

    it 'create' do
      custom_fields
      cf_values = custom_fields.inject({}) {|k, v| k[v.id.to_s] = "value#{v.name}"; k}
      expect {
        post :create, custom_entity: { custom_table_id: custom_table.id, custom_field_values: cf_values }
      }.to change { CustomEntity.count }.by(1)
      custom_values = assigns(:custom_entity).custom_values.inject({}) {|k, v| k[v.custom_field_id.to_s] = v.value; k}
      expect(cf_values == custom_values ).to be true
      expect(response).to redirect_to(custom_entity_path(assigns(:custom_entity)))

      Role.non_member.remove_permission! :manage_tables
      User.current.reload
      post :create, custom_entity: { custom_table_id: custom_table.id, custom_field_values: cf_values }
      expect(response).to have_http_status(403)
    end

    it 'with belongs to cf' do
      custom_value
      post :create,
           project_id: project.id,
           parent_entities_cf_ids: [sub_custom_field.id.to_s],
           custom_entity: { custom_table_id: sub_custom_table.id, custom_field_values: {sub_custom_field.id.to_s => custom_entity.id.to_s} }

      parent_entities = assigns[:custom_entity].parent_entities
      values = assigns[:custom_entity].custom_values

      expect(values.first.customized_id).to eq assigns[:custom_entity].id
      expect(values.first.custom_entity_id).to eq parent_entities.first.id
      expect(values.first.value).to eq parent_entities.first.name
    end

  end

  it 'get edit' do
    get :edit, id: custom_entity
    expect(response).to have_http_status(:success)
    expect(response).to render_template('custom_entities/edit')

    Role.non_member.remove_permission! :manage_tables
    get :edit, id: custom_entity
    expect(response).to have_http_status(403)
  end

  context 'update' do

    it 'update' do
      custom_value
      cf_values = custom_entity.custom_fields.inject({}) {|k, v| k[v.id.to_s] = "new_value"; k}

      put :update, id: custom_entity, custom_entity: { custom_field_values: cf_values }
      custom_entity.reload
      custom_values = assigns(:custom_entity).custom_values.inject({}) {|k, v| k[v.custom_field_id.to_s] = v.value; k}
      expect(cf_values == custom_values ).to be true
      expect(response).to redirect_to(custom_entity_path(assigns(:custom_entity)))

      Role.non_member.remove_permission! :manage_tables
      put :update, id: custom_entity.id, custom_entity: { custom_field_values: cf_values }
      expect(response).to have_http_status(403)
    end

    it 'with belongs to cf' do
      custom_value
      sub_custom_value
      put :update,
           id: sub_custom_entity.id,
           parent_entities_cf_ids: [sub_custom_field.id.to_s],
           custom_entity: { custom_table_id: sub_custom_table.id, custom_field_values: {sub_custom_field.id.to_s => custom_entity.id.to_s} }
      parent_entity = assigns[:custom_entity].parent_entities.first
      value = assigns[:custom_entity].custom_values.first

      expect(value.customized_id).to eq assigns[:custom_entity].id
      expect(value.custom_entity_id).to eq parent_entity.id
      expect(value.value).to eq custom_value.value

      custom_value.update_attributes(value: '123')
      value.reload
      expect(value.value).to eq custom_value.value
    end

  end

  it 'update notes' do
    expect {
      put :update, id: custom_entity, custom_entity: { notes: 'notes' }
    }.to change(Journal, :count)
  end

  it 'delete' do
    custom_value
    table = custom_entity.custom_table
    custom_entity_id = custom_entity.id
    expect(CustomValue.where(customized_id: custom_entity_id).count).to eq 1
    expect {delete :destroy, {id: custom_entity}}.to change(CustomEntity, :count).by(-1)
    expect(CustomValue.where(customized_id: custom_entity_id).count).to eq 0
    expect(response).to redirect_to(project_custom_table_path(table, project_id: table.project.identifier))

    Role.non_member.remove_permission! :manage_entities
    Role.non_member.remove_permission! :manage_tables
    User.current.reload
    delete :destroy, id: custom_entity
    expect(response).to have_http_status(403)
  end

  it 'bulk delete' do
    custom_entity
    custom_entity_2
    table = custom_entity.custom_table
    expect {delete :destroy, {ids: [custom_entity.id, custom_entity_2.id]}}.to change(CustomEntity, :count).by(-2)
    expect(response).to redirect_to(project_custom_table_path(table, project_id: table.project.identifier))
  end

  context 'Api' do
    let!(:custom_table) { FactoryGirl.create(:custom_table, name: 'Servers') }
    let!(:custom_entity_1) { FactoryGirl.create(:custom_entity, custom_table_id: custom_table.id ) }
    let!(:custom_entity_2) { FactoryGirl.create(:custom_entity, custom_table_id: custom_table.id ) }

    let!(:custom_field_1) { FactoryGirl.create(:custom_field, custom_table_id: custom_table.id, name: 'Server name') }
    let!(:custom_field_2) { FactoryGirl.create(:custom_field, custom_table_id: custom_table.id, name: 'IP-address') }
    let!(:custom_field_3) { FactoryGirl.create(:custom_field, custom_table_id: custom_table.id, name: 'the server.app') }

    let!(:custom_value_1) { FactoryGirl.create(:custom_value, customized_id: custom_entity_1.id, custom_field_id: custom_field_1.id, value: 'gladsquid' ) }
    let!(:custom_value_2) { FactoryGirl.create(:custom_value, customized_id: custom_entity_1.id, custom_field_id: custom_field_2.id, value: '111.222.333.444' ) }
    let!(:custom_value_3) { FactoryGirl.create(:custom_value, customized_id: custom_entity_1.id, custom_field_id: custom_field_3.id, value: 'app' ) }

    let!(:custom_value_4) { FactoryGirl.create(:custom_value, customized_id: custom_entity_2.id, custom_field_id: custom_field_1.id, value: 'zelonya.com' ) }
    let!(:custom_value_5) { FactoryGirl.create(:custom_value, customized_id: custom_entity_2.id, custom_field_id: custom_field_2.id, value: '1.2.3.4' ) }
    let!(:custom_value_6) { FactoryGirl.create(:custom_value, customized_id: custom_entity_2.id, custom_field_id: custom_field_3.id, value: 'app2' ) }

    it 'get json show' do
      get :show, id: custom_entity_1, format: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to match({
                                                   server: {
                                                     server_name: 'gladsquid',
                                                     ip_address: '111.222.333.444',
                                                     the_server_app: 'app'
                                                   }.stringify_keys
                                                 }.stringify_keys)
    end
  end

end