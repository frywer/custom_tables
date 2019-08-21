require "spec_helper"

describe CustomTable, type: :model do

  let(:role) { FactoryBot.create(:role) }
  let(:member) { FactoryBot.create(:member) }
  let(:user) { FactoryBot.create(:user, memberships: [member]) }
  let(:custom_table) { FactoryBot.create(:custom_table, visible: false, roles: user.roles) }

  describe 'visible' do

    it 'when table is visible' do
      expect(CustomTable.visible(user)).to include custom_table
    end

    context 'should be invisible' do
      let(:user) { FactoryBot.create(:user) }
      it 'user is not member' do
        expect(CustomTable.visible(user)).not_to include custom_table
      end
    end

  end
end