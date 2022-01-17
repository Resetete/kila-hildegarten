class TeamMember < ApplicationRecord
  belongs_to :content, dependent: :destroy
  accepts_nested_attributes_for :content

  belongs_to :image, dependent: :destroy
  accepts_nested_attributes_for :image
end
