class RequireResourceTypeSelection < ActiveRecord::Migration[8.1]
  def change
    change_column_default :resources, :resource_type, from: "property", to: nil
  end
end