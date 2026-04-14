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
end
