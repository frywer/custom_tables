require "spec_helper"

RSpec.describe "issues/_query_custom_table" do
  include_context 'logged as admin'
  helper(QueriesHelper)

  let(:issue) { FactoryBot.create(:issue) }
  let(:custom_table) { FactoryBot.create(:custom_table) }


  it "Displays no data" do
    render partial: "issues/query_custom_table", locals: {
        query: custom_table.query,
        custom_table: custom_table,
        back_url: issue_path(issue),
        entities: custom_table.query.results_scope }

    expect(rendered).to match /No data to display/
  end

end