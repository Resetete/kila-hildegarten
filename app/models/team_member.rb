class TeamMember < ApplicationRecord
  has_one :content
  has_one :image

  accepts_nested_attributes_for :content, allow_destroy: true
end
