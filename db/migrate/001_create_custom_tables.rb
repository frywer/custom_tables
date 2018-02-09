class CreateCustomTables < ActiveRecord::Migration
  def change
    create_table :custom_tables do |t|
      t.string :name
      t.references :project, null: true
      t.references :author, null: false
      t.timestamps null: false
    end
  end
end
