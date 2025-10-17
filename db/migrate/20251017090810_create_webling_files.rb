class CreateWeblingFiles < ActiveRecord::Migration[6.1]
  def change
    create_table :webling_files do |t|
      t.string :webling_id, null: false
      t.string :content_type
      t.timestamps
    end

    add_index :webling_files, :webling_id, unique: true
  end
end
