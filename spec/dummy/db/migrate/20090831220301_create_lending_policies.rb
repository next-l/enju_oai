class CreateLendingPolicies < ActiveRecord::Migration
  def self.up
    create_table :lending_policies do |t|
      t.integer :item_id, :null => false
      t.integer :user_group_id, :null => false
      t.integer :loan_period, :default => 0, :null => false
      t.datetime :fixed_due_date
      t.integer :renewal, :default => 0, :null => false
      t.integer :fine, :default => 0, :null => false
      t.text :note
      t.integer :position

      t.timestamps
    end
    add_index :lending_policies, [:item_id, :user_group_id], :unique => true
  end

  def self.down
    drop_table :lending_policies
  end
end
