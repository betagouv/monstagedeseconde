import React, { useEffect, useState } from 'react';
import { useDebounce } from 'use-debounce';
import Downshift from 'downshift';
import RadiusInput from './RadiusInput';
import { fetch } from 'whatwg-fetch';
import { endpoints} from '../../utils/api';
import { addParamToSearchParams, updateURLWithParam } from '../../utils/urls';

const COMPONENT_FOCUS_LABEL = 'location';

// see: https://geo.api.gouv.fr/decoupage-administratif/communes
// and
// 'https://geo.api.gouv.fr/communes?codePostal=78000' --> code curl
// 'https://geo.api.gouv.fr/communes?code=78646&fields=code,nom,codesPostaux,code

function CityInput({
  city: defaultCity,
  latitude: defaultLatitude,
  longitude: defaultLongitude,
  radius: defaultRadius,
  whiteBg: whiteBg }) {
  const searchParams = new URLSearchParams(window.location.search);

  const [cityOrZipcode, setCity] = useState(searchParams.get('city') || defaultCity || "");
  const [latitude, setLatitude] = useState(searchParams.get('latitude') || defaultLatitude || "");
  const [longitude, setLongitude] = useState(searchParams.get('longitude') || defaultLongitude || "");
  const [radius, setRadius] = useState(searchParams.get('radius') || defaultRadius || 60_000);
  // const [whiteBg, setWhiteBg] = useState(searchParams.get('whiteBg') || defaultWhiteBg || true);
  const [searchResults, setSearchResults] = useState([]);
  const [cityDebounced] = useDebounce(cityOrZipcode, 1000);
  const [focus, setFocus] = useState(null);
  const inputChange = (event) => {
    setCity(event.target.value);
    if (event.target.value == "") {
      setLatitude("")
      setLongitude("")
    }
  };
  const endpoint = endpoints['searchCitiesByNameOrZipcode']();
  const setLocation = (item) => {
    if (item) {
      setCity(item.nom);
      setLatitude(item.centre.coordinates[1]);
      setLongitude(item.centre.coordinates[0]);
      const cityParams = addParamToSearchParams('city', item.nom);
      updateURLWithParam(cityParams);
      const latitudeParams = addParamToSearchParams('latitude', item.centre.coordinates[1]);
      updateURLWithParam(latitudeParams);
      const longitudeParams = addParamToSearchParams('longitude', item.centre.coordinates[0]);
      updateURLWithParam(longitudeParams);
      const radiusParams = addParamToSearchParams('radius', radius);
      updateURLWithParam(radiusParams);
    }
  };

  const isZipcode = (str) => {
    return (str.length == 5 && !isNaN(str))
  }

  const searchCityByNameOrByZipcode = () => {
    isZipcode(cityOrZipcode) ? searchByZipcode(cityOrZipcode) : searchCityByName(cityOrZipcode);
  };

  const manageResults = (results) => {
    setSearchResults(results);
    setLocation(results[0]);
  };

  const searchCityByName = () => {
    const searchParams = new URLSearchParams();

    searchParams.append('nom', cityOrZipcode);
    searchParams.append('fields', ['nom', 'centre', 'departement', 'codesPostaux'].join(','));
    searchParams.append('limit', 10);
    searchParams.append('boost', 'population');
    endpoint.search = searchParams.toString();
    fetch(endpoint)
      .then((response) => response.json())
      .then(manageResults);
  };
  // zipcodes represent a set of communes referenced with a code.
  // This set represents an area that have a center from which a radius can be used for other search criteria
  const searchByZipcode = (zipcode) => {
    const searchParams = new URLSearchParams();

    searchParams.append('codePostal', zipcode);
    endpoint.search = searchParams.toString();

    fetch(endpoint)
      .then((response) => response.json())
      .then((jsonResponse) => searchByCode(jsonResponse[0]))
  };

  const searchByCode = (responseWithCode) => {
    if (responseWithCode == undefined || responseWithCode.code == undefined) {
      setCity(cityOrZipcode + " : code postal invalide")
    } else {
      const code = responseWithCode.code
      const searchParams = new URLSearchParams();

      searchParams.append('code', code);
      searchParams.append('nom', responseWithCode.nom);
      searchParams.append('fields', ['nom', 'centre', 'departement', 'codesPostaux', 'code'].join(','));
      searchParams.append('limit', 10);
      searchParams.append('boost', 'population');
      endpoint.search = searchParams.toString();

      fetch(endpoint)
        .then((response) => response.json())
        .then(manageResults);
    }
  };

  const codePostauxSample = (codes) => {
    let zipcode = ""
    if (codes.length == undefined || codes.length === 0) { return zipcode; }
    if (codes.length >= 1) { zipcode = codes[0]; }
    if (codes.length >= 2) { zipcode += ", " + codes[1]; }
    if (codes.length > 2) { zipcode += ", ... " }
    return `(${zipcode})`;
  };

  useEffect(() => {
    if (cityDebounced && cityDebounced.length > 3) {
      searchCityByNameOrByZipcode(cityDebounced);
    }
  }, [cityDebounced]);

  return (

    <>
      <input type="hidden" name="latitude" value={latitude} />
      <input type="hidden" name="longitude" value={longitude} />

      <Downshift
        initialInputValue={cityOrZipcode || ""}
        onChange={setLocation}
        selectedItem={cityOrZipcode}
        itemToString={(item) => (item ? item.nom : '')}
      >
        {({
          getInputProps,
          getItemProps,
          getLabelProps,
          getMenuProps,
          isOpen,
          inputValue,
          highlightedIndex,
          selectedItem,
          openMenu,
        }) => (
          <div className='fr-input-group mb-md-0 col-md '>
            <label {...getLabelProps({ className: `${(whiteBg) ? 'fr-label' : 'font-weight-lighter'}`, htmlFor: "input-search-by-city-or-zipcode" })}>
                   Commune ou code postal
            </label>
            <div
              id="test-input-location-container"
              title="Resultat de recherche"
              className={`input-group col p-0`}
            >

              <input
                {...getInputProps({
                  onChange: inputChange,
                  value: inputValue,
                  className: 'fr-input',
                  name: 'city',
                  id: 'input-search-by-city-or-zipcode',
                  placeholder: 'Choisissez une commune dans la liste',
                  maxLength: "50",
                  "aria-label": "Autour de",
                  onFocus: (event) => {
                    openMenu(event);
                  },
                })}
              />

              <div className="search-in-place bg-white shadow">
                <ul
                  {...getMenuProps({
                    className: 'p-0 m-0',
                    "aria-labelledby": 'input-search-by-city-or-zipcode',
                  })}
                >
                  {(isOpen || focus == COMPONENT_FOCUS_LABEL) && (
                    <li>
                      <RadiusInput radius={radius} setRadius={setRadius} focus={focus} setFocus={setFocus} />
                    </li>
                  )}
                  {!(isOpen || focus == COMPONENT_FOCUS_LABEL) && (
                    <input id="radius" type="hidden" name='radius' value={radius} />
                  )}
                  {isOpen
                    ? searchResults.length > 0 ? 
                      searchResults.map((item, index) => (
                        <li
                          {...getItemProps({
                            className: `py-2 px-3 listview-item ${highlightedIndex === index ? 'highlighted-listview-item' : ''
                              }`,
                            key: item.code,
                            index,
                            item,
                            style: {
                              fontWeight: selectedItem === item ? 'bold' : 'normal',
                            },
                          })}
                        >
                          {`${item.nom} ${codePostauxSample(item.codesPostaux)}`}
                        </li>
                      )) : (<li className='fr-p-1w'>Choisissez un nom de ville ou un code postal</li>)
                    : null}
                </ul>
              </div>
            </div>
          </div>
        )}
      </Downshift>
    </>
  );
}

export default CityInput;
