class FixTeamMembersContentIdColumn < ActiveRecord::Migration[6.1]
  def change
    return unless column_exists?(:team_members, :contents_id)

    remove_index :team_members, :contents_id if index_exists?(:team_members, :contents_id)

    rename_column :team_members, :contents_id, :content_id

    add_index :team_members, :content_id unless index_exists?(:team_members, :content_id)
  end
end
