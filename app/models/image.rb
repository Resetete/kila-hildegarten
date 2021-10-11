class Image < ApplicationRecord
  mount_uploader :picture, PictureUploader

  validates_presence_of :name, :picture, :page
  validate :picture_size
  validate :total_upload_limit

  MAX_FILE_SIZE = 5
  MAX_IMAGES_ON_HOMEPAGE = 2
  TOTAL_UPLOAD_LIMIT = 40

  private

  def picture_size
    if picture.size > MAX_FILE_SIZE.megabytes
      errors.add(:picture, "Maximale Bildgröße #{MAX_FILE_SIZE} MB")
    end
  end

  def total_upload_limit
    errors.add(:picture, "Maximale Anzahl (#{TOTAL_UPLOAD_LIMIT}) an Bildern erreicht. Bitte lösche Bilder und versuche es erneut.") if Image.all.count >= TOTAL_UPLOAD_LIMIT
  end
end
