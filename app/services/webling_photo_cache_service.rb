# app/services/webling_photo_cache_service.rb
class WeblingPhotoCacheService
  def initialize(photo_id:, webling_api_key: Rails.application.credentials.dig(:webling, :api_key))
    @photo_id = photo_id
    @api_key  = webling_api_key
  end

  def fetch_or_store!
    record = WeblingFile.find_or_initialize_by(webling_id: @photo_id)

    return record.file.blob if record.file.attached?

    data = download_photo_from_webling
    return nil unless data

    mime_type = Marcel::MimeType.for(StringIO.new(data))
    record.file_type = mime_type.start_with?('video') ? 'video' : 'image'

    record.file.attach(
      io: StringIO.new(data),
      filename: "webling_file_#{@photo_id}#{file_extension_for(mime_type)}",
      content_type: mime_type
    )

    record.save!
    record.file.blob
  rescue => e
    Rails.logger.error("WeblingPhotoCacheService error for #{@photo_id}: #{e.message}")
    nil
  end

  private

  def file_extension_for(mime)
    return '.mp4' if mime.include?('video')
    return '.jpg' if mime.include?('jpeg')
    return '.png' if mime.include?('png')
    ''
  end

  def download_photo_from_webling
    base_url = WeblingApiService::BASE_URL
    doc_resp = Faraday.get("#{base_url}/api/1/document/#{@photo_id}", {}, { 'apikey' => @api_key })
    return unless doc_resp.success?

    file_details = doc_resp.body
    file_url = "#{base_url}#{file_details.dig('properties', 'file', 'href')}"
    file_resp = Faraday.get(file_url, {}, { 'apikey' => @api_key })
    return file_resp.body if file_resp.success?

    Rails.logger.error("Failed to fetch photo content: #{file_resp.status}")
    nil
  end
end
