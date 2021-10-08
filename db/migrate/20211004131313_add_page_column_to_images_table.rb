class AddPageColumnToImagesTable < ActiveRecord::Migration[6.0]
  def change
    add_column :images, :page, :string
  end
end
