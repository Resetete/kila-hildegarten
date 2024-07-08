class WeblingPhotosController < ApplicationController
  protect_from_forgery with: :null_session

  layout 'bare'

  before_action :authorize_webling_user

  def index
    @subfolders_with_photo_ids = WeblingApiService.new.subfolders_with_photo_ids
  end

  def show
    photo_id = params[:id]

    # Fetch photo details
    photo_response = Faraday.get("#{WeblingApiService::BASE_URL}/api/1/document/#{photo_id}", {}, { 'apikey' => Rails.application.credentials.dig(:webling, :api_key) })

    if photo_response.success?
      photo_details = JSON.parse(photo_response.body)
      photo_url = "#{WeblingApiService::BASE_URL}#{photo_details.dig('properties', 'file', 'href')}"

      # Fetch the actual image content
      image_response = Faraday.get(photo_url, {}, { 'apikey' => Rails.application.credentials.dig(:webling, :api_key) })

      if image_response.success?
        # send image content with response
        send_data image_response.body, type: image_response.headers['content-type'], disposition: 'inline'
      else
        Rails.logger.error "Failed to fetch image content: #{image_response.body}"
        head :bad_request
      end
    else
      Rails.logger.error "Failed to fetch photo details: #{photo_response.body}"
      head :bad_request
    end
  end

  private

  def authorize_webling_user
    user = Admin.find_by(auth_token: params[:token])

    unless user && user.webling_user?
      redirect_to(root_path, status: :unauthorized, alert: 'Unauthorized')
    end
  end
end
