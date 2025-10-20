require 'zip'

class ZipStreamerService
  include Enumerable

  def initialize(webling_ids)
    @webling_ids = webling_ids
  end

  def each
    Zip::OutputStream.write_buffer do |zos|
      @webling_ids.each do |id|
        file = WeblingFile.find_by(webling_id: id)
        next unless file&.file&.attached?

        filename = sanitize_filename(file.file.filename.to_s)
        zos.put_next_entry(filename)
        file.file.download { |chunk| zos.write(chunk) }
      end
    end.tap do |buffer|
      buffer.rewind
      yield buffer.read
    end
  end

  private

  def sanitize_filename(name)
    name.gsub(/[^0-9A-Za-z.\-]/, '_')
  end
end
