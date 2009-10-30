class AddLatLngToAddresses < ActiveRecord::Migration
  def self.up
    add_column :addresses, :lat,  :decimal, :precision => 15, :scale => 10
    add_column :addresses, :lng,  :decimal, :precision => 15, :scale => 10
  end

  def self.down
    remove_column :addresses, :lat
    remove_column :addresses, :lng
  end
end
