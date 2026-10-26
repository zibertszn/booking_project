class UpdateResourcesForTypes < ActiveRecord::Migration[8.1]
  def change
    remove_check_constraint :resources, name: "resources_capacity_positive"
    remove_column :resources, :capacity, :integer

    add_column :resources, :resource_type, :string, null: false, default: "property"
    add_check_constraint :resources, "resource_type IN ('property', 'item')", name: "resources_resource_type_valid"
  end
end