import React, { useEffect, useState, useRef } from 'react';
import { useDebounce } from 'use-debounce';
// import { throttle, debounce } from "throttle-debounce";
import Downshift from 'downshift';
import { fetch } from 'whatwg-fetch';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import { endpoints } from '../../utils/api';
import { broadcast, newCoordinatesChanged, cityChanged, zipcodeChanged } from '../../utils/events';
import defaultMarker from '../../images/corporate_pin.svg';

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
  isDuplication,
  editMode
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
  const [mapVisible, setMapVisible] = useState(false);
  const [searchAddressVisible, setSearchAddressVisible] = useState(true);
  const [validatedAddress, setValidatedAddress] = useState(false);
  const [selectedAddress, setSelectedAddress] = useState('');

  const mapRef = useRef(null);
  const markerRef = useRef(null);
  const mapInstanceRef = useRef(null);

  const [fullAddressDebounced] = useDebounce(fullAddress, 100);

  // default coordinates (centre de la France)
  const defaultLatitude = 46.603354;
  const defaultLongitude = 1.888334;

  const handleMapClick = async (e) => {
    const { lat, lng } = e.latlng;
    
    // Supprimer l'ancien marqueur s'il existe
    if (markerRef.current) {
      markerRef.current.remove();
    }

    // Créer et ajouter le nouveau marqueur
    if (mapInstanceRef.current) {
      const customIcon = L.icon({
        iconUrl: defaultMarker,
        iconSize: [32, 32],
        iconAnchor: [16, 32],
        popupAnchor: [0, -32]
      });
      
      markerRef.current = L.marker([lat, lng], { icon: customIcon }).addTo(mapInstanceRef.current);
    }

    // Mettre à jour les coordonnées
    setLatitude(lat);
    setLongitude(lng);

    // get address from coordinates
    try {
      const response = await fetch(
        `https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}&addressdetails=1`
      );
      const data = await response.json();
      
      const address = data.address || {};

      const houseNumber = address.house_number || '';
      const road = address.road || '';
      const addressStreet = houseNumber ? `${houseNumber} ${road}` : road;
      setStreet(addressStreet);

      const addressPostcode = address.postcode || '';
      setZipcode(addressPostcode);

      const addressCity = address.city || address.town || address.village || '';
      setCity(addressCity);
      
      const formattedAddress = addressStreet + ' ' + addressPostcode + ' ' + addressCity;
      setSelectedAddress(formattedAddress);

      setValidAddress(addressStreet && typeof addressStreet === 'string' && addressStreet.trim() !== '');

      if (data.display_name) {
        // Diffuser les changements
        broadcast(newCoordinatesChanged({ latitude: lat, longitude: lng }));
        broadcast(cityChanged({ city: addressCity }));
        broadcast(zipcodeChanged({ zipcode: addressPostcode }));
      }
    } catch (error) {
      console.error("Erreur lors de la récupération de l'adresse:", error);
    }
  };



  const initializeMap = () => {
    if (!mapRef.current || typeof L === 'undefined') return;

    const initialLat = currentLatitude || defaultLatitude;
    const initialLng = currentLongitude || defaultLongitude;

    // create the map
    const map = L.map(mapRef.current, {
      zoomControl: true,
      scrollWheelZoom: true,
      doubleClickZoom: true,
      boxZoom: false,
      keyboard: false,
      dragging: true,
      touchZoom: true
    }).setView([initialLat, initialLng], 6);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© OpenStreetMap contributors'
    }).addTo(map);

    // add initial marker only if we have valid coordinates (not 0,0)
    if (currentLatitude && currentLongitude && 
        (currentLatitude !== 0 || currentLongitude !== 0)) {
      const customIcon = L.icon({
        iconUrl: defaultMarker,
        iconSize: [32, 32],
        iconAnchor: [16, 32],
        popupAnchor: [0, -32]
      });
      markerRef.current = L.marker([currentLatitude, currentLongitude], { icon: customIcon }).addTo(map);
    }

    map.on('click', handleMapClick);

    // force the size recalculation of the map
    setTimeout(() => {
      map.invalidateSize();
    }, 100);

    // Stocker la référence de la carte
    mapInstanceRef.current = map;

    return map;
  }

  const toggleMap = () => {
    if (mapVisible) {
      setSearchAddressVisible(true);
    } else {
      setSearchAddressVisible(false);
    }
    
    setMapVisible(prevState => {
      const newState = !prevState;
      return newState;
    });
  };

  const validateLocation = () => {
    if (latitude && longitude) {
      // close the map only after validation
      setMapVisible(false);
      setValidatedAddress(true);
      setAddressFieldsVisibility(true);
      setSearchAddressVisible(false);

      // remove required attribute from input
      document.querySelector('input[name="internship_occupation_autocomplete"]').removeAttribute('required');

    } else {
      alert('Veuillez sélectionner un emplacement sur la carte');
    }
  };

  const cancelLocation = () => {
    setValidatedAddress(false);
    setMapVisible(false);
    setAddressFieldsVisibility(false);
    setSearchAddressVisible(true);

    // add required attribute to input
    document.querySelector('input[name="internship_occupation_autocomplete"]').setAttribute('required', 'required');

    // empty street, zipcode, city and coordinates
    setStreet('');
    setZipcode('');
    setCity('');
    setLatitude(currentLatitude || 0);
    setLongitude(currentLongitude || 0);
    setSelectedAddress('');

    // display address input container
    document.querySelector('.address-input-container').style.display = 'block';
  };
  
  const inputChange = (event) => {
    setFullAddress(event.target.value);
  };

  const resetField = (e) => {
    e.stopPropagation();
    setFields(undefined);
    setAddressFieldsVisibility(false)
    broadcastReset();
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
        setQueryString(json.query); //for unknown reason, the query is not returned anymore
        setSearchResults(json.features);
      });
  };

  const setFullAddressComponents = (item) => {
    setFields(item)
    setAddressFieldsVisibility(true);
  };

  useEffect(() => {
    if (fullAddressDebounced && fullAddressDebounced.length > 3) {
      searchCityByAddress()
    }
  }, [fullAddressDebounced]);

  useEffect(() => {
    broadcast(newCoordinatesChanged({ latitude, longitude }));
  }, [latitude, longitude]);

  useEffect(() => {
    if (mapVisible && mapRef.current) {
      const map = initializeMap();
      
      // Cleanup function
      return () => {
        if (map) {
          map.remove();
        }
      };
    }
  }, [mapVisible]); // only watch mapVisible, not latitude or longitude

  return (
    <div className="address-input-container">
      <div className="form-group" id="test-input-full-address">
        
        {/* Search address */}
        { searchAddressVisible && (
          <div>
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
                        { isOpen && (searchResults !== undefined) && searchResults.map((item, index) => (
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
          </div>
        )}
        
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
      
        {/* Bouton pour afficher/masquer la carte */}
        {!validatedAddress ? (
          <button
            type="button"
            className="fr-btn fr-btn--secondary fr-mt-1w"
            onClick={toggleMap}
          >
            {mapVisible ? 'Masquer la carte' : 'Je ne trouve pas mon adresse'}
          </button>
        ) : (
          <button
            type="button"
            className="fr-btn fr-btn--secondary fr-mt-1w"
            onClick={cancelLocation}
          >
            Annuler l'adresse
          </button>
        )}

        <div className="localization-container">
          {/* Conteneur de la carte */}
          {mapVisible && (
            <div className="map-localization-container fr-mt-2w" style={{ position: 'relative', zIndex: 1000 }}>
              <div className="fr-alert fr-alert--info fr-alert--sm fr-mb-2w">
                <p className="fr-alert__title">Sélection d'emplacement</p>
                <p>Cliquez sur la carte pour placer un marqueur à l'emplacement souhaité. La carte restera ouverte pour vous permettre de repositionner le marqueur si nécessaire.</p>
              </div>

              <div
                ref={mapRef}
                style={{
                  height: '500px',
                  width: '100%',
                  border: '1px solid #ccc',
                  borderRadius: '4px',
                  overflow: 'hidden',
                  position: 'relative'
                }}
              />

              {selectedAddress && (
                <div className="fr-mt-2w">
                  <p className="fr-text--sm">
                    <strong>Adresse sélectionnée :</strong> {selectedAddress}
                  </p>
                </div>
              )}

              <div className="fr-mt-2w">
                <button
                  type="button"
                  className="fr-btn fr-btn--primary"
                  onClick={validateLocation}
                  disabled={!street}
                >
                  Valider cet emplacement
                </button>
                <button
                  type="button"
                  className="fr-btn fr-btn--secondary fr-ml-2w"
                  onClick={cancelLocation}
                >
                  Annuler
                </button>
              </div>
            </div>
          )}

          { (addressFieldsVisibility || isDuplication || editMode) && (
            <div className="form-row">
              <div className="col-sm-12 fr-mt-1w">
                <label htmlFor={`${resourceName}_internship_street`} className="fr-label">
                  Voie publique ou privée
                </label>
                <input
                  className="fr-input"
                  value={street}
                  type="text"
                  maxLength="200"
                  name={`${resourceName}[internship_street]`}
                  id={`${resourceName}_internship_street`}
                  readOnly
                />
              </div>
              <div className="col-sm-12 fr-mt-1w">
                <label htmlFor={`${resourceName}_internship_city`} className="fr-label">
                  Commune
                </label>
                <input
                  className="fr-input"
                  required="required"
                  value={city}
                  maxLength="50"
                  type="text"
                  name={`${resourceName}[internship_city]`}
                  id={`${resourceName}_internship_city`}
                  readOnly
                />
              </div>
              <div className="col-sm-12 fr-mt-1w">
                <label htmlFor={`${resourceName}_internship_zipcode`} className="fr-label">
                  Code postal
                </label>
                <input
                  className="fr-input"
                  required="required"
                  value={zipcode}
                  maxLength="5"
                  type="text"
                  name={`${resourceName}[internship_zipcode]`}
                  id={`${resourceName}_internship_zipcode`}
                  data-mandatory-fields-target="mandatoryField"
                  data-action="input->mandatory-fields#fieldChange"
                  readOnly
                />
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
