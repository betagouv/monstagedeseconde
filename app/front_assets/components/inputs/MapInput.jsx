import React, { useState, useEffect, useRef } from 'react';
import { broadcast, newCoordinatesChanged, cityChanged, zipcodeChanged } from '../../utils/events';
import defaultMarker from '../../images/corporate_pin.svg';

export default function MapInput({ resourceName, currentLatitude, currentLongitude }) {
  const [mapVisible, setMapVisible] = useState(false);
  const [selectedLatitude, setSelectedLatitude] = useState(currentLatitude || 0);
  const [selectedLongitude, setSelectedLongitude] = useState(currentLongitude || 0);
  const [selectedAddress, setSelectedAddress] = useState('');
  const mapRef = useRef(null);
  const markerRef = useRef(null);
  const [street, setStreet] = useState('');
  const [city, setCity] = useState('');
  const [zipcode, setZipcode] = useState('');
  const [validAddress, setValidAddress] = useState(false);
  const [validatedAddress, setValidatedAddress] = useState(false);

  // default coordinates (centre de la France)
  const defaultLatitude = 46.603354;
  const defaultLongitude = 1.888334;

  const handleMapClick = async (e) => {
    const { lat, lng } = e.latlng;

    // remove old marker if it exists
    if (markerRef.current) {
      markerRef.current.remove();
    }

    // create a custom icon with the imported image
    const customIcon = L.icon({
      iconUrl: defaultMarker,
      iconSize: [32, 32],
      iconAnchor: [16, 32],
      popupAnchor: [0, -32]
    });

    markerRef.current = L.marker([lat, lng], { icon: customIcon }).addTo(e.target);

    setSelectedLatitude(lat);
    setSelectedLongitude(lng);

    // get address from coordinates
    try {
      const response = await fetch(
        `https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}&addressdetails=1`
      );
      const data = await response.json();
      console.log(data);
      
      const address = data.address || {};
      console.log('address :', address);
      console.log('address road :', address.road);
      console.log('address house_number :', address.house_number);

      const houseNumber = address.house_number || '';
      const road = address.road || '';
      console.log('houseNumber :', houseNumber);
      console.log('road :', road);
      console.log('houseNumber ? `${houseNumber} ${road}` : road :', houseNumber ? `${houseNumber} ${road}` : road);
      const addressStreet = houseNumber ? `${houseNumber} ${road}` : road;
      setStreet(addressStreet);

      const addressPostcode = address.postcode || '';
      setZipcode(addressPostcode);

      const addressCity = address.city || address.town || address.village || '';
      setCity(addressCity);
      
      const formattedAddress = addressStreet + ' ' + addressPostcode + ' ' + addressCity;
      setSelectedAddress(formattedAddress);

      console.log('addressStreet :', addressStreet);
      console.log('addressStreet && addressStreet.trim() !== :', addressStreet && addressStreet.trim() !== '');
      console.log('addressStreet full :', addressStreet && typeof addressStreet === 'string' && addressStreet.trim() !== '');

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

    const initialLat = selectedLatitude || currentLatitude || defaultLatitude;
    const initialLng = selectedLongitude || currentLongitude || defaultLongitude;

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

    // add initial marker if coordinates exist
    if (currentLatitude && currentLongitude) {
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

    return map;
  };

  const toggleMap = () => {
    setMapVisible(!mapVisible);
    if (!mapVisible) {
      // remove address input container mandatory fields
      document.querySelector('.address-input-container').querySelectorAll('input[data-mandatory-fields-target="mandatoryField"]').forEach(input => {
        input.removeAttribute('data-mandatory-fields-target');
        input.removeAttribute('data-action');
      });
      // hide address input container
      document.querySelector('.address-input-container').style.display = 'none';

    } else {
      // show address input container
      document.querySelector('.address-input-container').style.display = 'block';
    }
  };

  const validateLocation = () => {
    if (selectedLatitude && selectedLongitude) {      
      // close the map only after validation
      setMapVisible(false);
      setValidatedAddress(true);

      // remove required attribute from input
      document.querySelector('input[name="internship_occupation_autocomplete').removeAttribute('required');

    } else {
      alert('Veuillez sélectionner un emplacement sur la carte');
    }
  };

  const cancelLocation = () => {
    setValidatedAddress(false);
    setMapVisible(false);

    // add required attribute to input
    document.querySelector('input[name="internship_occupation_autocomplete"]').setAttribute('required', 'required');

    // empty street, zipcode, city and coordinates
    setStreet('');
    setZipcode('');
    setCity('');
    setSelectedLatitude(currentLatitude || 0);
    setSelectedLongitude(currentLongitude || 0);
    setSelectedAddress('');

    // display address input container
    document.querySelector('.address-input-container').style.display = 'block';
  };

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
  }, [mapVisible]);

  return (
    <div className="localization-container">
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

      { validatedAddress && (
        <div className="form-row">
          <div className="col-sm-12 fr-mt-1w">
            <label htmlFor={`${resourceName}_street`} className="fr-label">
              Voie publique ou privée
            </label>
            <input
              className="fr-input"
              value={street}
              type="text"
              maxLength="200"
              name={`${resourceName}[street]`}
              id={`${resourceName}_street`}
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
              // data-mandatory-fields-target="mandatoryField"
              data-action="input->mandatory-fields#fieldChange"
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

          {/* hidden fields for coordinates */}
          <input
            id={`${resourceName}_coordinates_latitude`}
            value={selectedLatitude}
            name={`${resourceName}[coordinates][latitude]`}
            type="hidden"
          />
          <input
            id={`${resourceName}_coordinates_longitude`}
            value={selectedLongitude}
            name={`${resourceName}[coordinates][longitude]`}
            type="hidden"
          />
        </div>
      )}
    </div>
  );
}
