class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :resource, null: false, foreign_key: true
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false

      t.timestamps
    end

    add_index :bookings, [:resource_id, :starts_at]
    add_index :bookings, [:user_id, :starts_at]
    add_check_constraint :bookings, "ends_at > starts_at", name: "bookings_end_after_start"
  end
end