require "spec_helper"

describe CustomEntityQuery, type: :model do
  describe "#available_filters" do
    let!(:user) { FactoryBot.create(:user) }
    let!(:custom_entity_query) { described_class.new }
    let!(:custom_table) { FactoryBot.create(:custom_table, custom_fields: [
      { external_name: 'name', field_format: 'string'},
      { external_name: 'age', field_format: 'int' },
      { external_name: 'height', field_format: 'float' },
      { external_name: 'user', field_format: 'user' }
    ] ) }
    let(:user_custom_field) { custom_table.custom_fields.find { |cf| cf.field_format == 'user' } }
    let(:filter_options) { custom_entity_query.available_filters["cf_#{user_custom_field.id}"].values.flatten }

    context "when custom_table_id is nil" do
      before { custom_entity_query.initialize_available_filters }

      it "returns the custom field" do
        expect(filter_options).to include(user.id.to_s)
      end
    end

    context "when custom_table_id is present" do
      before do
        custom_entity_query.custom_table_id = custom_table.id
        custom_entity_query.initialize_available_filters
      end

      it "returns the custom field" do
        expect(filter_options).to include(user.id.to_s)
      end
    end
  end
end