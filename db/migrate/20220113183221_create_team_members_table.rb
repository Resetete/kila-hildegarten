class CreateTeamMembersTable < ActiveRecord::Migration[6.0]
  def change
    create_table :team_members do |t|
      t.name

      t.timestamps
  end
end

# a team member has one content (text) and one picture
# a picture does not need to have a team member (other pages contents)
# a content text does not need to have a team member (other pages contents)

# create a new team member form within a new image and content is stored and associated
# create new picture --> send the team member id with the url? to store it if a team member id ispresent if not store nil
