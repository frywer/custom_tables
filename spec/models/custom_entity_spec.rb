require "spec_helper"

describe CustomEntity, type: :model do
  describe '#imported_values' do
    let(:custom_table) { FactoryBot.create(:custom_table, custom_fields: [
      { external_name: 'name', field_format: 'string'},
      { external_name: 'age', field_format: 'int' },
      { external_name: 'height', field_format: 'float' }
    ] ) }

    let(:custom_entity) { CustomEntity.new(custom_table: custom_table, author: User.current) }

    context 'when values are valid' do
      it 'create custom_entity with external values' do
        custom_entity.external_values = { 'name' => 'My name',
                                          'age' => '21',
                                          'height' => '140.5' }

        expect(custom_entity.to_h).to eq({'name' => 'My name',
                                          'age' => '21',
                                          'height' => '140.5',
                                          'id' => custom_entity.id })
      end
    end
  end
end
