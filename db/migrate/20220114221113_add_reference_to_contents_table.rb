class AddReferenceToContentsTable < ActiveRecord::Migration[6.0]
  def change
    add_reference :contents, :team_member, index: true
  end
end
