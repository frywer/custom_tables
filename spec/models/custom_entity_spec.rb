require "spec_helper"

describe CustomEntity, type: :model do
  let(:custom_table) { FactoryBot.create(:custom_table, custom_fields: [
    { external_name: 'name', field_format: 'string'},
    { external_name: 'age', field_format: 'int' },
    { external_name: 'height', field_format: 'float' }
  ] ) }
  let(:external_values) {
    {
      'name' => 'My name',
      'age' => '21',
      'height' => '140.5'
    }
  }
  let(:role) { FactoryBot.create(:role) }
  let(:member) { FactoryBot.create(:member) }
  let(:user) { FactoryBot.create(:user, memberships: [member]) }
  describe '#imported_values' do
    let(:custom_entity) { CustomEntity.new(custom_table: custom_table, author: User.current) }

    context 'when values are valid' do
      it 'create custom_entity with external values' do
        custom_entity.external_values = external_values

        expect(custom_entity.to_h).to eq({'name' => 'My name',
                                          'age' => '21',
                                          'height' => '140.5',
                                          'id' => custom_entity.id })
      end
    end
  end

  describe '#visible?' do
    let(:custom_entity) { FactoryBot.create(:custom_entity, custom_table: custom_table, external_values: external_values) }

    subject { custom_entity.visible?(user) }

    context 'with permission' do
      it { is_expected.to be_truthy }
    end

    context 'without permission' do
      let(:user) { FactoryBot.create(:user) }

      it { is_expected.to be_falsey }
    end
  end
end
