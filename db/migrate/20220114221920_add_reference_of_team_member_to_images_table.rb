class AddReferenceOfTeamMemberToImagesTable < ActiveRecord::Migration[6.0]
  def change
    add_reference :images, :team_member, index: true
  end
end
