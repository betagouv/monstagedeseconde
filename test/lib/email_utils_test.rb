require 'test_helper'

class EmailUtilsTest < ActiveSupport::TestCase
  test '.env_host' do
    # This test is supposed to be ran on test env
    local_host = ENV['HOST']

    ENV['HOST'] = nil
    assert_equal  'https://stagedeseconde.1jeune1solution.gouv.fr', EmailUtils.env_host

    ENV['HOST'] = 'https://review.example.com'
    assert_equal  'https://review.example.com', EmailUtils.env_host

    ENV['HOST'] = local_host
  end

  test '.domain' do
    local_host = ENV.fetch('HOST')

    assert_equal 'localhost', EmailUtils.domain if Rails.env.development?

    ENV['HOST'] = 'https://stagedeseconde.recette.1jeune1solution.gouv.fr'
    assert_equal  'gouv.fr', EmailUtils.domain

    ENV['HOST'] = 'https://stagedeseconde.1jeune1solution.gouv.fr'
    assert_equal  'gouv.fr', EmailUtils.domain

    ENV['HOST'] = nil
    assert_equal  'gouv.fr', EmailUtils.domain

    ENV['HOST'] = local_host
  end

  test '.formatted_email' do
    assert_equal '"1Élève1Stage" <contact@1eleve1stage.education.gouv.fr>',
                 EmailUtils.formatted_email('contact@1eleve1stage.education.gouv.fr')
  end
end
