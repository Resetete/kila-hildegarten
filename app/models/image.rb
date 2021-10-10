class Image < ApplicationRecord
  mount_uploader :picture, PictureUploader

  validates_presence_of :name, :picture
  validate :picture_size
  MAX_FILE_SIZE = 5

  private

  def picture_size
    if picture.size > MAX_FILE_SIZE.megabytes
      errors.add(:picture, "Maximale Bildgröße #{MAX_FILE_SIZE} MB")
    end
  end
end
