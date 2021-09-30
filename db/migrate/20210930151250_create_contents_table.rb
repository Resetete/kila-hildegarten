class CreateContentsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :contents do |t|
      t.text :content # TODO: which type for long text?
      t.string :page # e.g. home, contact, imprint ...
      t.timestamps
    end
  end
end
