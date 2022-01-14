class Content < ApplicationRecord
  validates_presence_of :page
  belongs_to :team_member
end
