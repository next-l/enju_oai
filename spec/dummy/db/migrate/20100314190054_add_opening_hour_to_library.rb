class AddOpeningHourToLibrary < ActiveRecord::Migration[4.2]
  def self.up
    add_column :libraries, :opening_hour, :text
  end

  def self.down
    remove_column :libraries, :opening_hour
  end
end
