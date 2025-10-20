# this class loads the photos from Webling via API and caches it permanently through ActiveStorage (Cloudinary)
class WeblingPhotoCacheService
  def initialize(photo_id:, api_key: Rails.application.credentials.dig(:webling, :api_key))
    @photo_id = photo_id
    @api_key  = api_key
  end

  def fetch_or_store!
    # when the file already exists
    file = WeblingFile.find_by(webling_id: @photo_id)
    return file if file&.file&.attached?

    data = download_photo_from_webling
    return nil unless data

    mime_type = Marcel::MimeType.for(StringIO.new(data))
    filename  = "webling_photo_#{@photo_id}#{extension_for(mime_type)}"

    file ||= WeblingFile.create!(webling_id: @photo_id, content_type: mime_type)
    file.file.attach(
      io: StringIO.new(data),
      filename: filename,
      content_type: mime_type
    )
    file
  rescue => e
    Rails.logger.error("WeblingPhotoCacheService error for #{@photo_id}: #{e.class} - #{e.message}")
    nil
  end

  private

  def download_photo_from_webling
    base_url = WeblingApiService::BASE_URL
    doc_resp = Faraday.get("#{base_url}/api/1/document/#{@photo_id}", {}, { 'apikey' => @api_key })
    return unless doc_resp.success?

    file_details = JSON.parse(doc_resp.body)

    file_url = "#{base_url}#{file_details.dig('properties', 'file', 'href')}"
    file_resp = Faraday.get(file_url, {}, { 'apikey' => @api_key })

    return file_resp.body if file_resp.success?

    Rails.logger.error("Failed to fetch photo content (#{file_resp.status}) for #{@photo_id}")
    nil
  end

  def extension_for(mime_type)
    case mime_type
    when 'image/jpeg' then '.jpg'
    when 'image/png'  then '.png'
    when 'video/mp4'  then '.mp4'
    else ''
    end
  end
end
