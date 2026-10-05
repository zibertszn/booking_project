class CreateResources < ActiveRecord::Migration[8.1]
  def change
    create_table :resources do |t|
      t.string :name, null: false
      t.text :description
      t.integer :capacity, null: false, default: 1
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :resources, :name, unique: true
    add_check_constraint :resources, "capacity > 0", name: "resources_capacity_positive"
  end
end