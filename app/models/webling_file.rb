# This class is used to manage the webling photos and images
# retrieved from through the webling API
class WeblingFile < ApplicationRecord
  has_one_attached :file

  validates :webling_id, presence: true, uniqueness: true

  scope :photos, -> { where(file_type: 'image') }
  scope :videos, -> { where(file_type: 'video') }

  def image?
    file_type == 'image'
  end

  def video?
    file_type == 'video'
  end
end
