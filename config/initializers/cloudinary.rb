if Rails.application.credentials.dig(:cloudinary, :url) || ENV["CLOUDINARY_URL"]
  Cloudinary.config_from_url(
    Rails.application.credentials.dig(:cloudinary, :url) || ENV["CLOUDINARY_URL"]
  )
  Cloudinary.config.secure = true
end
