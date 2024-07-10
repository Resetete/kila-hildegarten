class WeblingPhotosController < ApplicationController
  protect_from_forgery with: :null_session
  before_action :allow_iframe_for_webling_photos, only: [:index]

  layout 'bare'

  before_action :authorize_webling_user

  def index
    @subfolders_with_photo_ids = WeblingApiService.new.subfolders_with_photo_ids
  end

  def show
    photo_id = params[:id]
    auth_token = Admin.find_by(role: 'webling_user').auth_token

    # Check if the image is cached
    cache_key = "webling_photo_#{photo_id}"
    image_content = Rails.cache.fetch(cache_key) do
      fetch_full_size_image(photo_id, auth_token)
    end

    if image_content.present?
      send_data image_content, type: 'image/jpeg', disposition: 'inline'
    else
      head :not_found
    end
  end

  def thumbnail
    photo_id = params[:id]
    auth_token = Admin.find_by(role: 'webling_user').auth_token

    # Check if the thumbnail is cached
    cache_key = "webling_thumbnail_#{photo_id}"
    thumbnail_content = Rails.cache.fetch(cache_key) do
      fetch_and_generate_thumbnail(photo_id, auth_token)
    end

    if thumbnail_content.present?
      send_data thumbnail_content, type: 'image/jpeg', disposition: 'inline'
    else
      head :not_found
    end
  end

  private

  def fetch_and_generate_thumbnail(photo_id, auth_token)
    # Fetch full-size image content
    full_size_image = fetch_full_size_image(photo_id, auth_token)

    if full_size_image.present?
      # Generate thumbnail using MiniMagick
      generate_thumbnail(full_size_image)
    else
      Rails.logger.error "Failed to fetch full-size image for thumbnail generation"
      nil
    end
  end

  def fetch_full_size_image(photo_id, auth_token)
    # Fetch photo details
    photo_response = Faraday.get("#{WeblingApiService::BASE_URL}/api/1/document/#{photo_id}", {}, { 'apikey' => Rails.application.credentials.dig(:webling, :api_key) })

    if photo_response.success?
      photo_details = JSON.parse(photo_response.body)
      photo_url = "#{WeblingApiService::BASE_URL}#{photo_details.dig('properties', 'file', 'href')}"

      # Fetch the actual image content
      image_response = Faraday.get(photo_url, {}, { 'apikey' => Rails.application.credentials.dig(:webling, :api_key) })

      if image_response.success?
        image_response.body
      else
        Rails.logger.error "Failed to fetch image content: #{image_response.body}"
        nil
      end
    else
      Rails.logger.error "Failed to fetch photo details: #{photo_response.body}"
      nil
    end
  end

  def authorize_webling_user
    user = Admin.find_by(auth_token: params[:token])

    unless user && user.webling_user?
      redirect_to(root_path, status: :unauthorized, alert: 'Unauthorized')
    end
  end

  def allow_iframe_for_webling_photos
    response.headers['Content-Security-Policy'] = "frame-ancestors 'self' https://hildegarten.webling.eu"
  end

  def generate_thumbnail(image_content)
    MiniMagick::Image.read(image_content)
                     .thumbnail("300x300")
                     .to_blob
  end
end
