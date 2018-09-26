require File.expand_path('../../test_helper', __FILE__)

class TableFieldsControllerTest < ActionController::TestCase

  fixtures :projects

  ActiveRecord::FixtureSet.create_fixtures(Redmine::Plugin.find(:custom_tables).directory + '/test/fixtures/', [:custom_tables])

  test "should get new" do
    get :new, custom_table_id: 1
    assert_template 'new'
    assert_select 'label#custom_field_field_format'
  end

  test "should get edit" do
    get :edit, custom_table_id: 1
    assert_template 'edit'
    assert_select 'label#custom_field_field_format'
  end


end
