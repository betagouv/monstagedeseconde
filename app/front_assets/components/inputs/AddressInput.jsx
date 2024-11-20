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
  addressFieldsVisible,
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
  const [addressFieldsVisibility, setAddressFieldsVisibility] = useState(addressFieldsVisible);
  const [fullAddressDebounced] = useDebounce(fullAddress, 100);


  const inputChange = (event) => {
    setFullAddress(event.target.value);
  };

  const resetField = (e) => {
    e.stopPropagation();
    setFields(undefined);
    broadcastReset();
    setAddressFieldsVisibility(false)
  };

  const broadcastReset = () => {
    broadcast(cityChanged({ city: "" }));
    broadcast(zipcodeChanged({ zipcode: "" }));
    broadcast(newCoordinatesChanged({ latitude: 0, longitude: 0 }));
  };

  const setFields = (item) => {
    if( item === undefined) {
      setFullAddress("");
      setStreet("");
      setCity("");
      setZipcode("");
      setLatitude(0);
      setLongitude(0);
    } else  {
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
      setZipcode(item.properties.postcode);
      setLatitude(parseFloat(item.geometry.coordinates[1]));
      setLongitude(parseFloat(item.geometry.coordinates[0]));
      broadcast(zipcodeChanged({ zipcode : item.properties.postcode}));
      broadcast(cityChanged({ city: item.properties.city }));
    }
  }

  const searchCityByAddress = () => {
    fetch(endpoints.apiSearchAddress({ fullAddress }))
      .then((response) => response.json())
      .then((json) => {
        setQueryString(json.query);
        setSearchResults(json.features);
      });
  };

  const setFullAddressComponents = (item) => {
    setFields(item)
    setAddressFieldsVisibility(true);
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
                  Rechercher une adresse postale*
                </label>

                <div className="d-flex">
                  <input
                    {...getInputProps({
                      onChange: inputChange,
                      onClick: resetField,
                      value: fullAddress,
                      className: 'fr-input flex-grow-1',
                      name: `${resourceName}_autocomplete`,
                      id: `${resourceName}_autocomplete`,
                      placeholder: '',
                      required: true,
                    })}
                  />

                  <div className="input-group-append">
                    <a onClick={resetField}>
                      <button className="fr-btn fr-btn--tertiary" type="button">
                        Effacer
                      </button>
                    </a>
                  </div>
                </div>

                <div className="search-in-place bg-white shadow">
                  <ul
                    {...getMenuProps({
                      className: 'p-0 m-0',
                    })}
                  >
                    { isOpen && (queryString === fullAddress) && (searchResults !== undefined) && searchResults.map((item, index) => (
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
                    }
                  </ul>
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
      { addressFieldsVisibility && (
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
              data-mandatory-fields-target="mandatoryField"
              data-action="input->mandatory-fields#fieldChange"
              readOnly
            />
          </div>
        </div>)
        }
    </div>
  );
}
