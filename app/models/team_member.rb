class TeamMember < ApplicationRecord
  has_many :contents, dependent: :destroy
  accepts_nested_attributes_for :contents

  has_many :images, dependent: :destroy
  accepts_nested_attributes_for :images
end
