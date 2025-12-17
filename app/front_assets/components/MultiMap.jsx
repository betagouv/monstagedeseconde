import React, { useEffect } from 'react';
import { MapContainer, TileLayer, Marker, Popup, useMap } from 'react-leaflet';
import MarkerClusterGroup from 'react-leaflet-cluster';
import L from 'leaflet';
import PropTypes from 'prop-types';

import defaultMarker from '../images/corporate_pin.svg';

const defaultPointerIcon = new L.Icon({
  iconUrl: defaultMarker,
  iconSize: [50, 58], // size of the icon
  iconAnchor: [20, 58], // changed marker icon position
  popupAnchor: [0, -60], // changed popup position
});

const FitBounds = ({ corporations }) => {
  const map = useMap();

  useEffect(() => {
    if (corporations && corporations.length > 0) {
      const bounds = L.latLngBounds(corporations.map((c) => [c.lat, c.lon]));
      map.fitBounds(bounds, { padding: [50, 50], maxZoom: 15 });
    }
  }, [corporations, map]);

  return null;
};

FitBounds.propTypes = {
  corporations: PropTypes.arrayOf(
    PropTypes.shape({
      lat: PropTypes.number,
      lon: PropTypes.number,
    }),
  ).isRequired,
};

const MultiMap = ({ corporations }) => {
  if (!corporations || corporations.length === 0) {
    return null;
  }

  // Calculate center of the map based on markers for initial render
  const positions = corporations.map((c) => [c.lat, c.lon]);
  const centerLat = positions.reduce((sum, pos) => sum + pos[0], 0) / positions.length;
  const centerLon = positions.reduce((sum, pos) => sum + pos[1], 0) / positions.length;
  const center = [centerLat, centerLon];

  return (
    <div className="row fr-my-2w">
      <div className="col-12 map-container-offer">
        <MapContainer center={center} zoom={12} scrollWheelZoom={false}>
          <FitBounds corporations={corporations} />
          <TileLayer
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
            url="https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png"
          />
          <MarkerClusterGroup>
            {corporations.map((corporation) => (
              <Marker
                key={corporation.id}
                icon={defaultPointerIcon}
                position={[corporation.lat, corporation.lon]}
              >
                <Popup>
                  <strong>{corporation.name}</strong>
                  <br />
                  {corporation.address}
                </Popup>
              </Marker>
            ))}
          </MarkerClusterGroup>
        </MapContainer>
      </div>
    </div>
  );
};

MultiMap.propTypes = {
  corporations: PropTypes.arrayOf(
    PropTypes.shape({
      id: PropTypes.number,
      lat: PropTypes.number,
      lon: PropTypes.number,
      name: PropTypes.string,
      address: PropTypes.string,
    }),
  ).isRequired,
};

export default MultiMap;
