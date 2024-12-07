module InternshipOccupationFormFiller
  def fill_in_internship_occupation_form(description: "Observation du métier de boulanger en boutique et à l'atelier",
                                         full_address: '12 rue taine par')
    body = File.read(
      Rails.root.join(
        *%w[test
            fixtures
            files
            12-rue-taine-paris.json]
      )
    ).to_json
    expected_endpoint = 'https://api-adresse.data.gouv.fr/search?q=12+rue+taine+paris&limit=10'
    expected_response = { status: 200, body: body }
    stub_request(:get, expected_endpoint).to_return(expected_response)

    fill_in "Indiquez le ou les métiers qui seront observables par l'élève", with: 'Observation du métier de boulanger'
    fill_in 'Décrivez les activités qui seront proposées à l’élève',
            with: description
    find_field('Rechercher une adresse postale*').native.send_keys(full_address[0..-2])
    find_field('Rechercher une adresse postale*').native.send_keys(full_address[-1])
  end
end
