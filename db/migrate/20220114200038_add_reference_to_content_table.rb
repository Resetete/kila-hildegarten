class AddReferenceToContentTable < ActiveRecord::Migration[6.0]
  def change
    add_reference :team_members, :contents, index: true
  end
end
