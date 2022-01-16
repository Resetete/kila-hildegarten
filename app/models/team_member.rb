class TeamMember < ApplicationRecord
  has_many :contents
  accepts_nested_attributes_for :contents #, allow_destroy: true

  has_many :images
  accepts_nested_attributes_for :images #, allow_destroy: true
end
