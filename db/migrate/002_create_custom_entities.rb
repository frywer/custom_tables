class CreateCustomEntities < ActiveRecord::Migration
  def change
    create_table :custom_entities do |t|
      t.references :custom_table, null: false, index: true
      t.references :author, null: false
    end
  end
end
