class RemoveReferences < ActiveRecord::Migration[6.0]
  def change
    remove_reference :images, :team_member, index: true
    remove_reference :contents, :team_member, index: true
  end
end
