class ChangeTeamMemberContentsIdToContentId < ActiveRecord::Migration[6.0]
  def change
    rename_column :team_members, :contents_id, :content_id
  end
end
