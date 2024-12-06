class Company
  def self.contact_message(with_carriage_return: false)
    current_year = SchoolYear::Current.new.end_of_period.year
    dates_data = SchoolTrack::Seconde.period_collection(school_year: current_year)[:full_time]

    'Bonjour,J’ai identifié votre entreprise sur le module Stages de 2de générale et technologique '\
    'du ministère de l’éducation nationale (plateforme 1 jeune 1 solution). Immersion Facilitée a '\
    'en effet signalé que vous êtes disposés à accueillir des élèves de seconde générale et '\
    "technologique pour leur séquence d’observation en milieu professionnel entre le #{dates_data[:start]} et "\
    "le #{dates_data[:end]} #{dates_data[:month]} #{dates_data[:year]}. " \
    "#{with_carriage_return ? '\n\n' : ''}" \
    '***Rédigez ici votre email de motivation.***Pourriez-vous me contacter '\
    "#{with_carriage_return ? '\n\n' : ''}" \
    'par mail ou par téléphone pour échanger sur mon projet de découverte de vos métiers ? '\
    'Vous trouverez sur cet URL le modèle de convention à utiliser : '\
    'https://www.education.gouv.fr/sites/default/files/ensel643_annexe1.pdf '\
    'Avec mes remerciements anticipés.'
  end
end
