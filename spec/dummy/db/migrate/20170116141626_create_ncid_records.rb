class CreateNcidRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :ncid_records do |t|
      t.string :body, index: {unique: true}, null: false
      t.references :manifestation, foreign_key: true, type: :uuid, null: false

      t.timestamps
    end
  end
end
