module InternshipOfferInfoFormFiller
  def fill_in_internship_offer_info_form(sector:)
    # fill_in 'Métier(s) à découvrir', with: 'Stage de test'
    select sector.name, from: "Secteur d'activité" if sector

    selector = '#internship_offer_info_title'
    title = 'Stage de test'
    find(selector).native.send_keys(title)

    selector = '#internship_offer_info_description'
    description = "Le dev plus qu'une activité, un lifestyle. Venez découvrir comment creer les outils qui feront le monde de demain"
    find(selector).set(description)
  end
end
