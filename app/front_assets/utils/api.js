const host = `${document.location.protocol}//${document.location.host}`;

export const endpoints = {
  // @post
  apiSchoolsNearby: ({ latitude, longitude }) => {
    const endpoint = new URL(`${host}/api/schools/nearby`);
    const searchParams = new URLSearchParams();

    searchParams.append('latitude', latitude);
    searchParams.append('longitude', longitude);
    endpoint.search = searchParams.toString();

    return endpoint;
  },

  // @get
  apiSearchAddress: ({ fullAddress }) => {
    const endpoint = new URL(`${host}/api_address_proxy/search`);
    const searchParams = new URLSearchParams();

    searchParams.append('q', fullAddress);
    searchParams.append('limit', 10);
    endpoint.search = searchParams.toString();

    return endpoint;
  },

  // @post
  apiInternshipOfferKeywordsSearch: ({ keyword }) => {
    const endpoint = new URL(`${host}/internship_offer_keywords/search`);
    const searchParams = new URLSearchParams();

    searchParams.append('keyword', keyword);
    endpoint.search = searchParams.toString();

    return endpoint;
  },

  // @get
  searchCompanyBySiren: ({ siren }) => {
    const endpoint = new URL(`${host}/api_sirene_proxy/search`);
    const searchParams = new URLSearchParams();

    searchParams.append('siren', siren);
    endpoint.search = searchParams.toString();
    return endpoint;
  },

  // @get
  searchCompanyBySiret: ({ siret }) => {
    const endpoint = new URL(`${host}/api_sirene_proxy/search`);
    const searchParams = new URLSearchParams();

    searchParams.append('siret', siret);
    endpoint.search = searchParams.toString();
    return endpoint;
  },

  // @get
  searchCompanyByName: ({ name }) => {
    const endpoint = new URL(`${host}/api_entreprise_proxy/search`);
    const searchParams = new URLSearchParams();

    searchParams.append('name', name);
    endpoint.search = searchParams.toString();
    return endpoint;
  },

  // @post
  apiSearchSchool: () => {
    const endpoint = new URL(`${host}/api/v1/schools/search`);
    return endpoint;
  },

  // @get
  apiRomeQuery: ({keyword}) => {
    const endpoint = new URL(`${host}/api/v2/coded_crafts/search`);
    const searchParams = new URLSearchParams();

    searchParams.append('keyword', keyword);
    endpoint.search = searchParams.toString();
    console.log(endpoint);
    return endpoint;
  },

  // @get
  searchInternshipOffers: () => {
    const endpoint = new URL(`${host}/offres-de-stage.json`);
    const searchParams = new URLSearchParams();

    endpoint.search = searchParams.toString();
    return endpoint;
  },

  // @post
  addFavorite: ({ internship_offer_id }) => {
    const endpoint = new URL(`${host}/favorites.json`);

    return endpoint;
  },

  // @del
  removeFavorite: ({ id }) => {
    const endpoint = new URL(`${host}/favorites/${id}.json`);
    const searchParams = new URLSearchParams();

    searchParams.append('id', id);
    endpoint.search = searchParams.toString();

    return endpoint;
  },

  // @get
  searchCitiesByNameOrZipcode: () => {
    const endpoint = new URL(`${host}/api_city_proxy/search`);
    return endpoint;
  }
};
