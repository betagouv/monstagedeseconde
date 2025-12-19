def populate_multi_activities
  employer = Users::Employer.first

  MultiActivity.create!(
    employer: employer,
    title: 'Découverte des métiers du numérique',
    description: "Une journée d'immersion pour découvrir les différents métiers du développement web, du design et de la gestion de projet. Au programme : rencontre avec des développeurs, initiation au code, et ateliers créatifs."
  )

  MultiActivity.create!(
    employer: employer,
    title: 'Atelier CV et lettre de motivation',
    description: "Apprenez à rédiger un CV percutant et une lettre de motivation adaptée pour vos recherches de stage. Nos experts RH vous donneront les clés pour réussir vos candidatures."
  )
  
  MultiActivity.create!(
    employer: employer,
    title: 'Visite de chantier BTP',
    description: "Venez découvrir les coulisses d'un grand chantier de construction. Sécurité, logistique, métiers manuels et ingénierie seront abordés lors de cette visite guidée."
  )
end

call_method_with_metrics_tracking([:populate_multi_activities])

