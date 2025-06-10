class DesinterlaceSchoolSignatureJob < ApplicationJob
  queue_as :default

  def perform(school_id)
    school = School.find_by(id: school_id)
    return unless school&.signature&.attached?

    require 'mini_magick'

    signature = school.signature
    blob = signature.blob

    downloaded_file = Tempfile.new(['signature', '.png'])
    downloaded_file.binmode
    downloaded_file.write(blob.download)
    downloaded_file.rewind

    image = MiniMagick::Image.open(downloaded_file.path)
    if image.type == 'PNG' && image['interlace'] != 'None'
      image.interlace 'None'
      image.format 'png'
      # Reattach the new image
      school.signature.attach(
        io: StringIO.new(image.to_blob),
        filename: blob.filename,
        content_type: blob.content_type
      )
    end
  ensure
    downloaded_file.close! if downloaded_file
  end
end
