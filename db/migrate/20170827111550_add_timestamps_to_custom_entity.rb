class AddTimestampsToCustomEntity < ActiveRecord::Migration[4.2]
  def change
    add_column :custom_entities, :created_at, :datetime, null: true
    add_column :custom_entities, :updated_at, :datetime, null: true
  end
end
