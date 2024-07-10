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

    # Fetch photo details
    photo_response = fetch_photo_details(photo_id)
    # photo_response = Faraday.get("#{WeblingApiService::BASE_URL}/api/1/document/#{photo_id}", {}, { 'apikey' => Rails.application.credentials.dig(:webling, :api_key) })

    if photo_response.success?
      photo_details = JSON.parse(photo_response.body)
      photo_url = "#{WeblingApiService::BASE_URL}#{photo_details.dig('properties', 'file', 'href')}"

      # Fetch the actual image content
      image_response = fetch_image(photo_url)

      if image_response.success?
        send_data(image_response.body, type: image_response.headers['content-type'], disposition: 'inline')
      else
        handle_failed_image_fetch(image_response)
      end
    else
      handle_failed_photo_details_fetch(photo_response)
    end
  end

  def thumbnail
    photo_id = params[:id]

    # Fetch photo details
    photo_response = fetch_photo_details(photo_id)

    if photo_response.success?
      photo_details = JSON.parse(photo_response.body)
      photo_url = "#{WeblingApiService::BASE_URL}#{photo_details.dig('properties', 'file', 'href')}"

      # Fetch the actual image content
      image_response = fetch_image(photo_url)

      if image_response.success?
        thumbnail_image = generate_thumbnail(image_response.body)
        send_data(thumbnail_image, type: image_response.headers['content-type'], disposition: 'inline')
      else
        handle_failed_image_fetch(image_response)
      end
    else
      handle_failed_photo_details_fetch(photo_response)
    end
  end

  private

  def fetch_photo_details(photo_id)
    Faraday.get("#{WeblingApiService::BASE_URL}/api/1/document/#{photo_id}", {}, { 'apikey' => Rails.application.credentials.dig(:webling, :api_key) })
  end

  def fetch_image(photo_url)
    Faraday.get(photo_url, {}, { 'apikey' => Rails.application.credentials.dig(:webling, :api_key) })
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

  def handle_failed_image_fetch(response)
    Rails.logger.error "Failed to fetch image content: #{response.body}"
    head :bad_request
  end

  def handle_failed_photo_details_fetch(response)
    Rails.logger.error "Failed to fetch photo details: #{response.body}"
    head :bad_request
  end

  def generate_thumbnail(image_content)
    MiniMagick::Image.read(image_content)
                     .thumbnail("300x300")
                     .to_blob
  end
end
