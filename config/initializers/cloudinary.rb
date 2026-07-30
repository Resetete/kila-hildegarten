if Rails.application.credentials.dig(:cloudinary, :url) || ENV["CLOUDINARY_URL"]
  Cloudinary.config_from_url(ENV["CLOUDINARY_URL"] || Rails.application.credentials.dig(:cloudinary, :url))
  Cloudinary.config.secure = true
end
