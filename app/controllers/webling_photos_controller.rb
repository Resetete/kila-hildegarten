class WeblingPhotosController < ApplicationController
  require 'streamio-ffmpeg'

  protect_from_forgery with: :null_session
  before_action :allow_iframe_for_webling_photos, only: [:index]
  before_action :authorize_webling_user

  layout 'bare'

  def index
   @auth_token = @current_user.auth_token
  end

  def fetch_files
    @subfolders_with_photo_ids = fetch_files_from_service
    render json: @subfolders_with_photo_ids
  end

  def show
    photo_id = params[:id]
    auth_token = Admin.find_by(auth_token: params[:token])&.auth_token

    unless auth_token
      head :unauthorized and return
    end

    # Check if the image is cached
    cache_key = "webling_photo_#{photo_id}"
    file_content = Rails.cache.fetch(cache_key) do
      fetch_full_size_file(photo_id, auth_token)
    end

    if file_content.present?
      send_data(file_content, type: image?(file_content) ? 'image/jpeg' : 'video/mp4', disposition: 'inline')
    else
      head :not_found
    end
  end

  def thumbnail
    photo_id = params[:id]
    auth_token = Admin.find_by(auth_token: params[:token])&.auth_token

    unless auth_token
      head :unauthorized and return
    end

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

  def fetch_files_from_service
    WeblingApiService.new.subfolders_with_photo_ids
  end

  def fetch_and_generate_thumbnail(photo_id, auth_token)
    # Fetch full-size image content
    full_size_image = fetch_full_size_file(photo_id, auth_token)

    if full_size_image.present?
      # Generate thumbnail using MiniMagick
      generate_thumbnail(full_size_image)
    else
      Rails.logger.error "Failed to fetch full-size image for thumbnail generation"
      nil
    end
  end

  def fetch_full_size_file(photo_id, auth_token)
    response = Faraday.get("#{WeblingApiService::BASE_URL}/api/1/document/#{photo_id}", {}, { 'apikey' => auth_token })

    if response.success?
      file_details = JSON.parse(response.body)
      file_url = "#{WeblingApiService::BASE_URL}#{file_details.dig('properties', 'file', 'href')}"

      # Fetch the actual image content
      file_response = Faraday.get(file_url, {}, { 'apikey' => auth_token })

      if file_response.success?
        file_response.body
      else
        Rails.logger.error "Failed to fetch image content: #{file_response.body}"
        nil
      end
    else
      Rails.logger.error "Failed to fetch file details: #{response.body}"
      nil
    end
  end

  def authorize_webling_user
    token = params[:token]
    @current_user = Admin.find_by(auth_token: token)

    unless @current_user && @current_user.webling_user?
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def allow_iframe_for_webling_photos
    response.headers['Content-Security-Policy'] = "frame-ancestors 'self' https://hildegarten.webling.eu"
  end

  def generate_thumbnail(file_content)
    if image?(file_content)
      generate_image_thumbnail(file_content)
    else
      generate_video_thumbnail(file_content)
    end
  end

  def generate_video_thumbnail(file_content)
    temp_video_path = Tempfile.new(['video', '.mp4'])
    temp_video_path.binmode
    temp_video_path.write(file_content)
    temp_video_path.rewind

    movie = FFMPEG::Movie.new(temp_video_path.path)
    temp_image_path = Tempfile.new(['thumbnail', '.jpg'])
    movie.screenshot(temp_image_path.path, seek_time: 5)

    thumbnail_content = File.binread(temp_image_path.path)

    temp_video_path.close!
    temp_image_path.close!

    thumbnail_content
  end

  def generate_image_thumbnail(file_content)
    MiniMagick::Image.read(file_content)
                      .thumbnail("300x300")
                      .to_blob
  end

  def image?(file_content)
    file_type = Marcel::MimeType.for(StringIO.new(file_content))
    file_type.start_with?('image')
  end
end
