# frozen_string_literal: true

require 'test_helper'

class GenerateMultiInternshipAgreementTest < ActiveSupport::TestCase
  test 'call renders a non empty pdf document' do
    internship_agreement = create(:multi_internship_agreement)

    pdf = GenerateMultiInternshipAgreement.new(internship_agreement.uuid).call
    rendered = pdf.render

    assert_kind_of Prawn::Document, pdf
    assert rendered.start_with?('%PDF-')
    assert_operator rendered.bytesize, :>, 1000
  end

  test 'call renders the school logo when attached' do
    internship_agreement = create(:multi_internship_agreement)
    internship_agreement.school.header_logo.attach(
      io: File.open(Rails.root.join('test/fixtures/files/signature.png')),
      filename: 'logo.png',
      content_type: 'image/png'
    )

    rendered = GenerateMultiInternshipAgreement.new(internship_agreement.uuid).call.render

    assert rendered.start_with?('%PDF-')
  end
end
