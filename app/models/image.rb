class Image < ApplicationRecord
  mount_uploader :picture, PictureUploader

  validates_presence_of :picture, :page
  validate :picture_size
  validate :total_upload_limit

  MAX_FILE_SIZE = 2.freeze
  MAX_IMAGES_ON_HOMEPAGE = 2.freeze
  MAX_IMAGES_ON_DAILY_LIFE_SECTION = 3.freeze
  TOTAL_UPLOAD_LIMIT = 50.freeze

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
