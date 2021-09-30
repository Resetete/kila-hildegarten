class CreateContentsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :contents do |t|
      t.text :content
      t.string :page
      t.timestamps
    end
  end
end
