class CreateZipCodes < ActiveRecord::Migration
  def self.up
    create_table :zip_codes do |t|
      t.string :zip
      t.string :state
      t.string :town
      # Database formatting per: http://snippets.dzone.com/posts/show/3216
      t.decimal "longitude", :precision => 15, :scale => 10
      t.decimal "latitude", :precision => 15, :scale => 10
      t.timestamps
    end
  end

  def self.down
    drop_table :zip_codes
  end
end
