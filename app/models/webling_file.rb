# This class is used to manage the webling photos and images
# retrieved from through the webling API
class WeblingFile < ApplicationRecord
  has_one_attached :file

  validates :webling_id, presence: true, uniqueness: true

  def image?
    content_type&.start_with?('image')
  end

  def video?
    content_type&.start_with?('video')
  end
end
