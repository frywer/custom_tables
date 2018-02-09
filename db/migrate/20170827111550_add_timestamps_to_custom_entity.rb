class AddTimestampsToCustomEntity < ActiveRecord::Migration
  def change
    add_column :custom_entities, :created_at, :datetime, null: false
    add_column :custom_entities, :updated_at, :datetime, null: false
  end
end
