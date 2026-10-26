class AddUserToResources < ActiveRecord::Migration[8.1]
  def change
    add_reference :resources, :user, foreign_key: true
  end
end
