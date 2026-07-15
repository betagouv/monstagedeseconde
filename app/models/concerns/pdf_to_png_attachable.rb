# frozen_string_literal: true

require "mini_magick"
require "tempfile"

# Prawn cannot embed PDF files as images: any ActiveStorage attachment
# declared with `pdf_to_png_attachable :name` is converted to PNG right
# after commit, so it can safely be drawn in generated agreements.
module PdfToPngAttachable
  extend ActiveSupport::Concern

  class_methods do
    def pdf_to_png_attachable(attachment_name)
      after_commit if: -> { pdf_attachment?(attachment_name) } do
        convert_pdf_attachment_to_png(attachment_name)
      end
    end
  end

  private

  def pdf_attachment?(attachment_name)
    attachment = public_send(attachment_name)
    attachment.attached? && attachment.content_type == "application/pdf"
  end

  def convert_pdf_attachment_to_png(attachment_name)
    return unless pdf_attachment?(attachment_name)

    attachment = public_send(attachment_name)
    begin
      temp_pdf = Tempfile.new([ attachment_name.to_s, ".pdf" ])
      temp_pdf.binmode
      temp_pdf.write(attachment.download)
      temp_pdf.close

      # Convert to PNG
      image = MiniMagick::Image.new(temp_pdf.path)
      image.format "png"

      # Reattach as PNG
      attachment.attach(
        io: StringIO.new(image.to_blob),
        filename: attachment.filename.to_s.sub(".pdf", ".png"),
        content_type: "image/png"
      )
    rescue StandardError => e
      Rails.logger.error "Erreur lors de la conversion PDF->PNG: #{e.message}"
      errors.add(attachment_name, "n'a pas pu être convertie en PNG")
    ensure
      # Cleanup
      temp_pdf.unlink if temp_pdf
    end
  end
end
