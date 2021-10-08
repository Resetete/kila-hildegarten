class Image < ApplicationRecord
  # image belongs to a page
  # a page has many images
  mount_uploader :picture, PictureUploader # picture is the attribute in the images table
end
