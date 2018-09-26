require File.expand_path('../../test_helper', __FILE__)

class CustomEntitiesControllerTest < ActionController::TestCase

  fixtures :projects

  ActiveRecord::FixtureSet.create_fixtures(Redmine::Plugin.find(:custom_tables).directory + '/test/fixtures/', [:custom_tables])

  test "should get new" do
    get :new
    assert_response :success
    assert_template 'new'
  end

  # test "should create" do
  #   assert_difference 'CustomTable.count' do
  #     post :create, project_id: 1, custom_table: {name: 'CRM'}
  #   end
  #   assert_redirected_to custom_table_path(CustomTable.last)
  #   table = CustomTable.where(name: "CRM").first
  #   assert_not_nil table
  #   assert_equal "CRM", table.name
  # end
  #
  # test "should get edit" do
  #   get :edit, id: 1
  #   assert_response :success
  #   assert_template 'edit'
  #   assert_select 'input#custom_table_name'
  #   assert_select 'select#custom_table_main_custom_field_id'
  # end
  #
  # test "should update" do
  #   @request.session[:user_id] = 1
  #   custom_table = CustomTable.find 1
  #   new_name = 'New name'
  #   put :update, id: custom_table, custom_table: {name: 'New name'}
  #   assert_redirected_to edit_custom_table_path(custom_table)
  #   custom_table.reload
  #   assert_equal new_name, custom_table.name
  # end
  #
  # test "should destroy" do
  #   @request.session[:user_id] = 1
  #   custom_table = CustomTable.find 1
  #   post :destroy, id: 1
  #   assert_redirected_to project_custom_tables_path(project_id: custom_table.project)
  #   assert_equal 0, CustomTable.where(id: 1).count
  # end
end
