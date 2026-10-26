class AddBookingTimeRangeConstraint < ActiveRecord::Migration[8.1]
  def up
    enable_extension "btree_gist" unless extension_enabled?("btree_gist")

    execute <<~SQL
      ALTER TABLE bookings
      ADD COLUMN booking_period tsrange
      GENERATED ALWAYS AS (tsrange(starts_at, ends_at, '[)')) STORED
    SQL

    execute <<~SQL
      ALTER TABLE bookings
      ADD CONSTRAINT bookings_no_resource_overlap
      EXCLUDE USING gist (resource_id WITH =, booking_period WITH &&)
    SQL
  end

  def down
    execute "ALTER TABLE bookings DROP CONSTRAINT IF EXISTS bookings_no_resource_overlap"
    remove_column :bookings, :booking_period
    disable_extension "btree_gist" if extension_enabled?("btree_gist")
  end
end