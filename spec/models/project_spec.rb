require "spec_helper"

describe Project, type: :model do

  let(:tracker) { FactoryBot.create(:tracker) }
  let(:project) { FactoryBot.create(:project, trackers: [tracker]) }
  let(:issue) { FactoryBot.create(:issue, project: project, tracker: tracker) }
  let(:custom_table) { FactoryBot.create(:custom_table, projects: [project], trackers: [tracker]) }


  it '#all_issue_custom_tables' do
    custom_table
    expect(project.all_issue_custom_tables(issue)).
        to include custom_table
  end
end