class AddTeamMemberReferenceToImagesTable < ActiveRecord::Migration[6.0]
  def change
    add_reference :team_members, :image, index: true
  end
end
