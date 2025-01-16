module EmailUtils
  def self.env_host
    ENV.fetch('HOST') { 'https://1eleve1stage.education.gouv.fr' }
  end

  def self.domain
    URI(env_host).host.split('.').last(2).join('.')
  end

  def self.from
    'contact@1eleve1stage.education.gouv.fr'
  end

  def self.formatted_from
    formatted_email(from)
  end

  def self.reply_to
    'contact@1eleve1stage.education.gouv.fr'
  end

  def self.formatted_reply_to
    formatted_email(reply_to)
  end

  def self.display_name
    '1Élève1Stage'
  end

  def self.formatted_email(email)
    address = Mail::Address.new
    address.address = email
    address.display_name = display_name
    address.format
  end
end
