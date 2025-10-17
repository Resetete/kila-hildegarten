class CreateWeblingFiles < ActiveRecord::Migration[6.1]
  def change
    create_table :webling_files do |t|
      t.integer :webling_id
      t.string :title
      t.string :file_type
      t.integer :folder_id

      t.timestamps
    end
  end
end
