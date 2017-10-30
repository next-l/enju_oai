class CreateEventExportFiles < ActiveRecord::Migration[5.1]
  def change
    create_table :event_export_files do |t|
      t.integer :user_id
      t.datetime :executed_at

      t.timestamps
    end
  end
end
