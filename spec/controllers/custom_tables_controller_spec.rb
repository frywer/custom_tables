require "spec_helper"

describe CustomTablesController, logged: true do

  render_views

  let(:project) { FactoryGirl.create(:project) }
  let(:custom_table) { FactoryGirl.create(:custom_table, project_id: project.id) }

  let(:custom_field) { FactoryGirl.create(:custom_field, custom_table_id: custom_table.id) }
  let(:custom_entity) { FactoryGirl.create(:custom_entity, custom_table_id: custom_table.id) }
  let(:custom_value) { FactoryGirl.create(:custom_value, customized_id: custom_entity.id, custom_field_id: custom_field.id) }

  before(:each) do
    role = Role.non_member
    role.add_permission! :show_tables
    role.add_permission! :manage_tables
    role.add_permission! :manage_entities
  end

  it 'get index' do
    get :index, project_id: project.id
    expect(response).to have_http_status(:success)
    expect(response).to render_template('custom_tables/index')

    Role.non_member.remove_permission! :manage_entities
    Role.non_member.remove_permission! :manage_tables
    User.current.reload

    get :index, project_id: project.id
    expect(response).to have_http_status(:success)

    Role.non_member.remove_permission! :show_tables
    User.current.reload
    get :index, project_id: project.id
    expect(response).to have_http_status(403)
  end

  it 'get show' do
    get :show, id: custom_table
    expect(response).to have_http_status(:success)
    expect(response).to render_template('custom_tables/show')

    Role.non_member.remove_permission! :manage_entities
    Role.non_member.remove_permission! :manage_tables
    User.current.reload

    get :show, id: custom_table
    expect(response).to have_http_status(:success)

    Role.non_member.remove_permission! :show_tables
    User.current.reload
    get :show, id: custom_table
    expect(response).to have_http_status(403)
  end

  it 'get new' do
    get :new, project_id: project.id
    expect(response).to have_http_status(:success)
    expect(response).to render_template('custom_tables/new')

    Role.non_member.remove_permission! :manage_tables
    User.current.reload
    get :new
    expect(response).to have_http_status(403)
  end

  it 'create' do
    expect {
      post :create, custom_table: { name: 'Contacts'}, project_id: project.identifier
    }.to change { CustomTable.count }.by(1)
    expect(response).to redirect_to(custom_table_path(assigns(:custom_table)))

    Role.non_member.remove_permission! :manage_tables
    User.current.reload
    post :create, custom_table: { name: 'Contacts'}, project_id: project.identifier
    expect(response).to have_http_status(403)
  end

  it 'get edit' do
    get :edit, id: custom_table
    expect(response).to have_http_status(:success)
    expect(response).to render_template('custom_tables/edit')

    Role.non_member.remove_permission! :manage_tables
    User.current.reload
    get :edit, id: custom_table
    expect(response).to have_http_status(403)
  end

  it 'update' do
    put :update, id: custom_table.id, custom_table: { name: 'Contacts updated'}
    custom_table.reload
    expect(custom_table.name).to eq('Contacts updated')
    expect(response).to redirect_to(edit_custom_table_path(assigns(:custom_table)))
  end

  it 'delete' do
    custom_value
    expect(CustomEntity.where(custom_table_id: custom_table.id).count).to eq 1
    expect(CustomField.where(custom_table_id: custom_table.id).count).to eq 1
    delete :destroy, id: custom_table
    expect(CustomEntity.where(custom_table_id: custom_table.id).count).to eq 0
    expect(CustomField.where(custom_table_id: custom_table.id).count).to eq 0
    expect(response).to redirect_to(project_custom_tables_path(project_id: project))

    Role.non_member.remove_permission! :manage_tables
    User.current.reload
    delete :destroy, id: custom_table
    expect(response).to have_http_status(403)
  end

  context 'query', logged: :admin do

    let(:custom_entity_1) { FactoryGirl.create(:custom_entity, custom_table_id: custom_table.id) }
    let(:custom_entity_2) { FactoryGirl.create(:custom_entity, custom_table_id: custom_table.id) }
    let(:custom_value_1) { FactoryGirl.create(:custom_value, customized_id: custom_entity_1.id, value: 'fine') }
    let(:custom_value_2) { FactoryGirl.create(:custom_value,  customized_id: custom_entity_2.id, value: 'not fine') }
    let(:custom_value_3) { FactoryGirl.create(:custom_value, customized_id: custom_entity_1.id, value: 'nice & fine') }
    let(:custom_table_1) { FactoryGirl.create(:custom_table, project_id: project.id, name: 'fine') }
    let(:custom_table_2) { FactoryGirl.create(:custom_table, project_id: project.id, name: 'not fine') }
    let(:custom_table_3) { FactoryGirl.create(:custom_table, project_id: project.id, name: 'nice & fine') }

    context 'search' do

      #Entities
      it 'entity' do
        custom_value_1
        custom_value_2
        get :show, id: custom_table, name_like: 'not'
        expect(assigns[:custom_entities].size).to eq 1
      end

      it 'entities' do
        custom_value_1
        custom_value_2
        get :show, id: custom_table, name_like: 'n'
        expect(assigns[:custom_entities].size).to eq 2
      end

      it '2 same in one enity' do
        custom_value_1
        custom_value_2
        custom_value_3
        get :show, id: custom_table, name_like: 'fine'
        expect(assigns[:custom_entities].size).to eq 2
      end

      # Tables
      it 'table' do
        custom_table_1
        custom_table_2
        get :index, project_id: project, name_like: 'not'
        expect(assigns[:custom_tables].size).to eq 1
      end

      it 'tables' do
        custom_table_1
        custom_table_2

        get :index, project_id: project, name_like: 'n'
        expect(assigns[:custom_tables].size).to eq 2
      end
    end

  end

  context 'Api' do
    let!(:custom_table) { FactoryGirl.create(:custom_table, name: 'Servers') }
    let!(:custom_entity_1) { FactoryGirl.create(:custom_entity, custom_table_id: custom_table.id ) }
    let!(:custom_entity_2) { FactoryGirl.create(:custom_entity, custom_table_id: custom_table.id ) }

    let!(:custom_field_1) { FactoryGirl.create(:custom_field, custom_table_id: custom_table.id, name: 'Server name', external_name: '') }
    let!(:custom_field_2) { FactoryGirl.create(:custom_field, custom_table_id: custom_table.id, name: 'IP-address') }
    let!(:custom_field_3) { FactoryGirl.create(:custom_field, custom_table_id: custom_table.id, name: 'the server.app') }

    let!(:custom_value_1) { FactoryGirl.create(:custom_value, customized_id: custom_entity_1.id, custom_field_id: custom_field_1.id, value: 'gladsquid' ) }
    let!(:custom_value_2) { FactoryGirl.create(:custom_value, customized_id: custom_entity_1.id, custom_field_id: custom_field_2.id, value: '111.222.333.444' ) }
    let!(:custom_value_3) { FactoryGirl.create(:custom_value, customized_id: custom_entity_1.id, custom_field_id: custom_field_3.id, value: 'app' ) }

    let!(:custom_value_4) { FactoryGirl.create(:custom_value, customized_id: custom_entity_2.id, custom_field_id: custom_field_1.id, value: 'zelonya.com' ) }
    let!(:custom_value_5) { FactoryGirl.create(:custom_value, customized_id: custom_entity_2.id, custom_field_id: custom_field_2.id, value: '1.2.3.4' ) }
    let!(:custom_value_6) { FactoryGirl.create(:custom_value, customized_id: custom_entity_2.id, custom_field_id: custom_field_3.id, value: 'app2' ) }

    it 'get json index' do
      get :show, id: custom_table, format: :json
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)).to match({'servers' =>
                                                    [
                                                      {'server_name' => 'gladsquid', 'ip_address' => '111.222.333.444', 'the_server_app' => 'app'},
                                                      {'server_name' => 'zelonya.com', 'ip_address' => '1.2.3.4', 'the_server_app' => 'app2'}
                                                    ]
                                                 })
    end
  end

end