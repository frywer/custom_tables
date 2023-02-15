require "spec_helper"

RSpec.describe "issues/_custom_tables" do
  include_context 'logged as'

  let(:tracker) { FactoryBot.create(:tracker) }
  let(:issue) { FactoryBot.create(:issue, tracker: tracker) }
  let(:custom_table) { FactoryBot.create(:custom_table) }

  before(:each) do
    allow_any_instance_of(Project).
        to receive(:all_issue_custom_tables).and_return([custom_table])
  end

  context 'without permission' do
    it "Displays no permission warning" do
      render partial: "issues/custom_tables", locals: { issue: issue }
      expect(rendered).to match /No permission to manage custom tables!/
    end
  end

  context 'with permission' do
    before(:each) do
      allow_any_instance_of(User).
          to receive(:allowed_to?).and_return(true)
    end

    it "Displays the custom table" do
      stub_template "issues/_query_custom_table.html.erb" => "<p>no content</p>"
      render partial: "issues/custom_tables", locals: { issue: issue }
      expect(rendered).to match /#{custom_table.name}/
    end
  end
end