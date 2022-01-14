class TeamMember < ApplicationRecord
  has_one :content
  has_one :image
end
