require "spec_helper"

RSpec.describe "custom_tables/new" do
  include_context 'logged as admin'

  let(:tracker) { FactoryBot.create(:tracker) }
  let(:role) { FactoryBot.create(:role) }
  let(:custom_table) { FactoryBot.create(:custom_table, description: 'Table desc', trackers: [tracker], roles: [role]) }

  before(:each) do
    @custom_table = assign(:custom_table, custom_table)
  end

  it "It displays description" do
    assign(:custom_table, custom_table)
    render
    expect(rendered).to match /Table desc/
  end

  it "It displays trackers" do
    assign(:custom_table, custom_table)
    render
    expect(rendered).to match /#{custom_table.trackers.first.name}/
  end

  it "It displays roles" do
    assign(:custom_table, custom_table)
    render
    expect(rendered).to match /#{custom_table.roles.first.name}/
  end


end