class Company
  def self.contact_message(with_carriage_return: false)
    current_year = SchoolYear::Current.new.end_of_period.year
    dates_data = SchoolTrack::Seconde.period_collection(school_year: current_year)[:full_time]

    'Bonjour,' \
    "#{with_carriage_return ? '\n\n' : ''}" \
    'J’ai identifié votre entreprise sur la plateforme 1élève1stage. Immersion ' \
    ' Facilitée a en effet signalé que vous êtes disposés à accueillir des élèves' \
    ' pour leur séquence d’observation en milieu professionnel.'
    "#{with_carriage_return ? '\n' : ''}" \
    '***Rédigez ici votre email de motivation.***Pourriez-vous me contacter '\
    'par mail ou par téléphone pour échanger sur mon projet de découverte de vos métiers ? '\
    "#{with_carriage_return ? '\n' : ''}" \
    'Avec mes remerciements anticipés.'
  end
end
