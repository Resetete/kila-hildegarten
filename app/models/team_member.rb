class TeamMember < ApplicationRecord
  has_many :contents
  accepts_nested_attributes_for :contents #, allow_destroy: true

  has_one :image
end
