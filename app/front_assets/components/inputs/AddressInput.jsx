import React, { useEffect, useState } from 'react';
import { useDebounce } from 'use-debounce';
// import { throttle, debounce } from "throttle-debounce";
import Downshift from 'downshift';
import { fetch } from 'whatwg-fetch';
import { endpoints } from '../../utils/api';
import { broadcast, newCoordinatesChanged, cityChanged, zipcodeChanged } from '../../utils/events';

// see: https://geo.api.gouv.fr/adresse
export default function AddressInput({
  resourceName,
  currentStreet,
  currentCity,
  currentZipcode,
  currentLatitude,
  currentLongitude,
  currentFullAddress,
}) {
  const [helpVisible, setHelpVisible] = useState(false);
  const [fullAddress, setFullAddress] = useState(currentFullAddress || '');
  const [street, setStreet] = useState(currentStreet || '');
  const [city, setCity] = useState(currentCity || '');
  const [zipcode, setZipcode] = useState(currentZipcode || '');
  const [latitude, setLatitude] = useState(currentLatitude || 0);
  const [longitude, setLongitude] = useState(currentLongitude || 0);
  const [searchResults, setSearchResults] = useState([]);
  const [detailedFieldsVisibility, setdetailedFieldsVisibility] = useState(false);
  const [queryString, setQueryString] = useState('');
  const [fullAddressDebounced] = useDebounce(fullAddress, 100);

  const inputChange = (event) => {
    setFullAddress(event.target.value);
  };

  const resetField = (e) => {
    e.stopPropagation();
    setFullAddress("");
    setStreet("");
    setCity("");
    setZipcode("");
    setLatitude(0);
    setLongitude(0);
    broadcast(cityChanged({ city: "" }));
    broadcast(zipcodeChanged({ zipcode: "" }));
    broadcast(newCoordinatesChanged({ latitude: 0, longitude: 0 }));
    setdetailedFieldsVisibility(false)
  };

  const toggleHelpVisible = (event) => {
    event.stopPropagation();
    setHelpVisible(!helpVisible);
  };
  const searchCityByAddress = () => {
    fetch(endpoints.apiSearchAddress({ fullAddress }))
      .then((response) => response.json())
      .then((json) => {
        setSearchResults(json.features)
        setQueryString(json.query)
      });
  };

  const setFullAddressComponents = (item) => {
    setFullAddress(item.properties.label);
    if (item.properties.housenumber === undefined) {
      setStreet(item.properties.name);
    } else {
      setStreet(
        [item.properties.housenumber, item.properties.street]
          .filter((component) => component)
          .join(' ')
      );
    };
    setCity(item.properties.city);
    broadcast(cityChanged({ city: item.properties.city }));
    setZipcode(item.properties.postcode);
    broadcast(zipcodeChanged({ zipcode : item.properties.postcode}));
    setLatitude(parseFloat(item.geometry.coordinates[1]));
    setLongitude(parseFloat(item.geometry.coordinates[0]));
    setdetailedFieldsVisibility(true);
  };

  useEffect(() => {
    if (fullAddressDebounced && fullAddressDebounced.length > 2) {
      searchCityByAddress()
    }
  }, [fullAddressDebounced]);

  useEffect(() => {
    broadcast(newCoordinatesChanged({ latitude, longitude }));
  }, [latitude, longitude]);

  return (
    <div>
      <div className="form-group" id="test-input-full-address">
        <div className="container-downshift">
          <Downshift
            initialInputValue={fullAddress}
            onChange={setFullAddressComponents}
            selectedItem={fullAddress}
            itemToString={(item) => {
              item && item.properties ? item.properties.label : '';
            }}
          >
            {({
              getLabelProps,
              getInputProps,
              getItemProps,
              getMenuProps,
              isOpen,
              highlightedIndex,
            }) => (
              <div>
                <label
                  {...getLabelProps({
                    className: 'label',
                    htmlFor: `${resourceName}_autocomplete`,
                  })}
                >
                  Adresse du lieu où se déroule le stage
                  <a
                    className="btn-absolute btn fr-btn btn-link py-0"
                    href="#help-multi-location"
                    aria-label="Afficher l'aide"
                    onClick={toggleHelpVisible}
                  >
                    <i className="fas fa-question-circle" />
                  </a>
                </label>

                <div className="input-group">
                  <input
                    {...getInputProps({
                      onChange: inputChange,
                      onClick: resetField,
                      value: fullAddress,
                      className: 'form-control',
                      name: `${resourceName}_autocomplete`,
                      id: `${resourceName}_autocomplete`,
                      placeholder: 'Adresse',
                      required: true,
                    })}
                  />

                  <div className="search-in-place bg-white shadow">
                    <ul
                      {...getMenuProps({
                        className: 'p-0 m-0',
                      })}
                    >
                      { isOpen && queryString === fullAddress
                        ? searchResults.map((item, index) => (
                            <li
                              {...getItemProps({
                                className: `py-2 px-3 listview-item ${
                                  highlightedIndex === index ? 'highlighted-listview-item' : ''
                                }`,
                                key: `${item.properties.id}-${item.properties.label}`,
                                index,
                                item,
                                style: {
                                  fontWeight: highlightedIndex === index? 'bold' : 'normal',
                                },
                              })}
                            >
                              {item.properties.label}
                            </li>
                          ))
                        : null}
                    </ul>
                  </div>
                <div className="input-group-append">
                  <a onClick={resetField}>
                    <span className="input-group-text">Effacer</span> 
                  </a>
                </div>
                </div>
              </div>
            )}
          </Downshift>
        </div>
        <div
          id="help-multi-location"
          className={`${helpVisible ? '' : 'd-none'} my-1 p-2 help-sign-content`}
        >
          Si vous proposez le même stage dans un autre établissement, déposez une offre par
          établissement. Si le stage est itinérant (la semaine se déroule sur plusieurs lieux),
          indiquez l'adresse où l'élève devra se rendre au premier jour
        </div>
        <input
          id={`${resourceName}_coordinates_latitude`}
          value={latitude}
          name={`${resourceName}[coordinates][latitude]`}
          type="hidden"
        />
        <input
          id={`${resourceName}_coordinates_longitude`}
          value={longitude}
          name={`${resourceName}[coordinates][longitude]`}
          type="hidden"
        />
      </div>
      { detailedFieldsVisibility && (
        <div className="form-row">
          <div className="col-sm-12 fr-mt-1w">
            <label htmlFor={`${resourceName}_street`} className="fr-label">
              Voie publique ou privée
            </label>
            <input
              className="fr-input"
              value={street}
              type="text"
              name={`${resourceName}[street]`}
              id={`${resourceName}_street`}
              readOnly
            />
          </div>
          <div className="col-sm-12 fr-mt-1w">
            <label htmlFor={`${resourceName}_city`} className="fr-label">
              Commune
            </label>
            <input
              className="fr-input"
              required="required"
              value={city}
              maxLength="50"
              type="text"
              name={`${resourceName}[city]`}
              id={`${resourceName}_city`}
              readOnly
            />
          </div>
          <div className="col-sm-12 fr-mt-1w">
            <label htmlFor={`${resourceName}_zipcode`} className="fr-label">
              Code postal
            </label>
            <input
              className="fr-input"
              required="required"
              value={zipcode}
              maxLength="5"
              type="text"
              name={`${resourceName}[zipcode]`}
              id={`${resourceName}_zipcode`}
              data-mandatory-fields-target="filledComponent"
              readOnly
            />
          </div>
        </div>
        )}
    </div>
  );
}
