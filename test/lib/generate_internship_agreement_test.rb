# frozen_string_literal: true

require 'test_helper'

class GenerateInternshipAgreementTest < ActiveSupport::TestCase
  test 'initialization applies expected layout defaults' do
    internship_agreement = create(:mono_internship_agreement)

    generator = GenerateInternshipAgreement.new(internship_agreement.id)
    pdf = generator.instance_variable_get(:@pdf)

    assert_equal [ 40, 572.0, 752.0, 90.0 ],
                 [ pdf.bounds.absolute_left,
                  pdf.bounds.absolute_right,
                  pdf.bounds.absolute_top,
                  pdf.bounds.absolute_bottom ]
    assert_equal 'Arial', pdf.font.family
  end

  test 'call renders a non empty pdf document' do
    internship_agreement = create(:mono_internship_agreement)

    pdf = GenerateInternshipAgreement.new(internship_agreement.id).call
    rendered = pdf.render

    assert_kind_of Prawn::Document, pdf
    assert rendered.start_with?('%PDF-')
    assert_operator rendered.bytesize, :>, 1000
  end

  test 'call renders header logos when school and employer logos are attached' do
    internship_agreement = create(:mono_internship_agreement)
    attach_png_logo(internship_agreement.school.header_logo)
    attach_png_logo(internship_agreement.employer.header_logo)

    without_logos = GenerateInternshipAgreement.new(internship_agreement.id)
    internship_agreement.school.header_logo.detach
    internship_agreement.employer.header_logo.detach

    rendered_without_logos = without_logos.call.render

    attach_png_logo(internship_agreement.school.header_logo)
    attach_png_logo(internship_agreement.employer.header_logo)
    rendered_with_logos = GenerateInternshipAgreement.new(internship_agreement.id).call.render

    assert rendered_with_logos.start_with?('%PDF-')
    assert_operator rendered_with_logos.bytesize, :>, rendered_without_logos.bytesize
  end

  test 'call survives a corrupted logo attachment' do
    internship_agreement = create(:mono_internship_agreement)
    internship_agreement.school.header_logo.attach(
      io: StringIO.new('not a real image'),
      filename: 'logo.png',
      content_type: 'image/png'
    )

    rendered = GenerateInternshipAgreement.new(internship_agreement.id).call.render

    assert rendered.start_with?('%PDF-')
  end

  private

  def attach_png_logo(attachment)
    attachment.attach(
      io: File.open(Rails.root.join('test/fixtures/files/signature.png')),
      filename: 'logo.png',
      content_type: 'image/png'
    )
  end
end
