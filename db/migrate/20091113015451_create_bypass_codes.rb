class CreateBypassCodes < ActiveRecord::Migration
  def self.up
    create_table :reg_ex_bypass_codes, :force => true do |t|
      t.string  :code
      t.date    :expiration
      t.timestamps
    end
  end

  def self.down
    drop_table :reg_ex_bypass_codes
  end
end