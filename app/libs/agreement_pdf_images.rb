# frozen_string_literal: true

require "mini_magick"

# Shared image helpers for the agreement PDF generators
# (GenerateInternshipAgreement and GenerateMultiInternshipAgreement).
module AgreementPdfImages
  LOGO_FIT = [ 100, 50 ].freeze

  # Prawn raises on interlaced PNG files: every ActiveStorage image is
  # re-encoded as a non-interlaced PNG before being drawn.
  def non_interlaced_png_io(attachment)
    return nil unless attachment&.attached?

    image = MiniMagick::Image.read(attachment.download)
    image.format "png"
    image.interlace "none"
    StringIO.new(image.to_blob)
  rescue StandardError => e
    Rails.logger.error "Error processing pdf image attachment: #{e.message} " \
                       "for internship agreement #{@internship_agreement&.id}"
    nil
  end

  # Draws the school logo (top left) and the employer logo (top right) on the
  # first page. Fail-safe: a missing or corrupted logo never blocks the PDF.
  def header_logos(school:, employer: nil)
    school_logo = non_interlaced_png_io(school.try(:header_logo))
    employer_logo = non_interlaced_png_io(employer.try(:header_logo))
    return if school_logo.nil? && employer_logo.nil?

    top = @pdf.cursor
    @pdf.image(school_logo, at: [ 0, top ], fit: LOGO_FIT) if school_logo
    @pdf.image(employer_logo, at: [ self.class::PAGE_WIDTH - LOGO_FIT.first, top ], fit: LOGO_FIT) if employer_logo
    @pdf.move_down LOGO_FIT.last + 10
  end
end
