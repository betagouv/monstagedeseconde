import React, { useEffect, useState } from 'react';
import { MapContainer, TileLayer, useMap, Marker, Popup } from 'react-leaflet';
import MarkerClusterGroup from 'react-leaflet-cluster';

import activeMarker from '../images/active_pin.svg';
import defaultMarker from '../images/default_pin.svg';
import boardingHouseMarker from '../images/icons/boarding_house_pin.svg';
import InternshipOfferCard from './InternshipOfferCard';
import CardLoader from './CardLoader';
import Paginator from './search_internship_offer/Paginator';
import TitleLoader from './TitleLoader';
import { endpoints } from '../utils/api';
import { isMobile } from '../utils/responsive';
import FlashMessage from './FlashMessage';
import ImmersionFaciliteeCard from './ImmersionFaciliteeCard';
import SearchBar from './search_internship_offer/SearchBar';

// France center
const center = [46.603354, 1.888334];

const pointerIcon = new L.Icon({
  iconUrl: activeMarker,
  iconSize: [50, 58], // size of the icon
  iconAnchor: [20, 58], // changed marker icon position
  popupAnchor: [0, -60], // changed popup position
});

const defaultPointerIcon = new L.Icon({
  iconUrl: defaultMarker,
  iconSize: [50, 58], // size of the icon
  iconAnchor: [20, 58], // changed marker icon position
  popupAnchor: [0, -60], // changed popup position
});

const boardingHouseIcon = new L.Icon({
  iconUrl: boardingHouseMarker,
  iconSize: [52, 70],
  iconAnchor: [26, 70],
  popupAnchor: [0, -70],
});

const InternshipOfferResults = ({
    searchParams,
    preselectedWeeksList,
    schoolWeeksList,
    secondeWeekIds,
    troisiemeWeekIds,
    studentGradeId,
    sectors
  }) => {
  // const [map, setMap] = useState(null);
  const [selectedOffer, setSelectedOffer] = useState(null);
  const [paginateLinks, setPaginateLinks] = useState(null);
  const [internshipOffers, setInternshipOffers] = useState([]);
  // const [showSectors, setShowSectors] = useState(false);
  // const [isSuggestion, setIsSuggestion] = useState(false);
  const [isLoading, setIsLoading] = useState(true);
  const [newDataFetched, setNewDataFetched] = useState(false);
  // const [selectedSectors, setSelectedSectors] = useState(searchParams['sector_ids'] || []);
  const [internshipOffersSeats, setInternshipOffersSeats] = useState(0);
  const [isFallbackSearch, setIsFallbackSearch] = useState(false);
  const [notify, setNotify] = useState(false);
  const [notificationMessage, setNotificationMessage] = useState('');
  const [params, setParams] = useState(searchParams);
  const [boardingHouses, setBoardingHouses] = useState([]);
  const [showBoardingHouses, setShowBoardingHouses] = useState(true);


  useEffect(() => {
    fetchInternshipOffers();
    fetchBoardingHouses();
  }, [params]);

  const ClickMap = ({ internshipOffers, boardingHouses, showBoardingHouses, recenterMap }) => {
    if (isMobile()) {return null };

    if (internshipOffers.length && recenterMap) {
      const map = useMap();
      const bounds = internshipOffers.map((internshipOffer) => [
        internshipOffer.lat,
        internshipOffer.lon,
      ]);
      if (showBoardingHouses && boardingHouses.length) {
        boardingHouses.forEach((bh) => {
          bounds.push([bh.lat, bh.lon]);
        });
      }
      map.fitBounds(bounds);
      // L.tileLayer.provider('CartoDB.Positron').addTo(map); MAP STYLE
    }

    setTimeout(() => setNewDataFetched(false), 100);
    return null;
  };

  const handleMouseOver = (data) => {
    setSelectedOffer(data);
  };

  const handleMouseOut = () => {
    // setSelectedOffer(null);
  };

  const fetchInternshipOffers = () => {
    setIsLoading(true);
    $.ajax({ type: 'GET', url: endpoints['searchInternshipOffers'](), data: params })
     .done(fetchDone)
     .fail(fetchFail);
  };

  const fetchBoardingHouses = () => {
    if (!params.latitude || !params.longitude) return;

    $.ajax({
      type: 'GET',
      url: endpoints['searchBoardingHouses'](),
      data: {
        latitude: params.latitude,
        longitude: params.longitude,
        radius: params.radius || 60000
      }
    }).done((result) => {
      setBoardingHouses(result.boardingHouses || []);
    });
  };

  const fetchDone = (result) => {
    setInternshipOffers(result['internshipOffers']);
    setPaginateLinks(result['pageLinks']);
    setInternshipOffersSeats(result['seats']);
    setIsFallbackSearch(result['isFallbackSearch'] || false);

    setIsLoading(false);
    setNewDataFetched(true);

    return true
  };

  const fetchFail = (xhr, textStatus) => {
    if (textStatus === 'abort') {
      return;
    }
    // setRequestError('Une erreur est survenue, veuillez ré-essayer plus tard.');
  };

  const sendNotification = (message) => {
    setNotify(true);
    setNotificationMessage(message);
  };

  const hideNotification = () => {
    setNotify(false);
  };

  return (
    <div className="">
      {/* SEARCH FORM */}
      <div className="fr-container">
        <div id="desktop_internship_offers_index_search_form">
          <div className="row fr-py-4w">
            <div className="col-12">
              <SearchBar
                searchParams={searchParams}
                preselectedWeeksList={preselectedWeeksList}
                schoolWeeksList={schoolWeeksList}
                secondeWeekIds={secondeWeekIds}
                troisiemeWeekIds={troisiemeWeekIds}
                origin='search'
                studentGradeId={studentGradeId}
                sectors={sectors}
              />
            </div>
          </div>
        </div>
      </div>
       <div className="results-container search-offer-bloc">
      {notify && <FlashMessage message={notificationMessage} display={notify} hideNotification={hideNotification} />}
      <div className="row fr-mx-0 fr-px-0">
        <div className={`${isMobile() ? 'col-12 px-1w' : 'col-7 px-0'}`}>

          <div className="scrollable-content d-flex justify-content-end">
            <div className="results-col fr-mt-2w fr-mx-1w">
              <div className="row fr-py-2w mx-0 ">
                <div className="col-12 px-0">
                  { isLoading ? (
                    <div className="row fr-mb-2w">
                      <TitleLoader />
                    </div>
                    ) : params.latitude != 0 && params.longitude!=0 && (
                        <>
                          <div className="h4 mb-0" id="internship-offers-count">
                            <div className="strong">
                              {internshipOffersSeats.toString().replace(/\B(?=(\d{3})+(?!\d))/g, " ")} stage{internshipOffersSeats > 1 ? 's' : ''} disponible{internshipOffersSeats > 1 ? 's' : ''}
                            </div>
                          </div>
                        </>
                      )
                  }
                  { !isLoading && isFallbackSearch && internshipOffersSeats > 0 && (
                    <div className="fr-alert fr-alert--info fr-my-2w">
                      <p>Aucune offre ne correspond exactement à vos critères. Voici des suggestions proches de votre recherche.</p>
                    </div>
                  )}
                  { !isLoading && (internshipOffersSeats == 0) &&
                    (<p>Aucune offre répondant à vos critères n'est disponible.<br/>Vous pouvez modifier vos filtres et relancer votre recherche.</p>)
                  }
                </div>
                  </div>

                <div> {/* Cards */}
                  {
                    (isLoading )?  (
                    <div className="row">
                        <div className={`col-${isMobile() ? '12' : '6'}`}>
                        <CardLoader />
                      </div>
                        <div className={`col-${isMobile() ? '12' : '6'}`}>
                        <CardLoader />
                      </div>
                        <div className={`col-${isMobile() ? '12' : '6'}`}>
                        <CardLoader />
                      </div>
                    </div>
                    ) : (
                      <div>
                        <div className="row">
                          { internshipOffers.map((internshipOffer, i) => (
                              <InternshipOfferCard
                                internshipOffer={internshipOffer}
                                key={internshipOffer.id}
                                index={i}
                                handleMouseOut={handleMouseOut}
                                handleMouseOver={(value) => {handleMouseOver(value)}}
                                sendNotification={(message) => {sendNotification(message)}}
                                />
                            )) }
                        </div>
                      <div>
                        {(paginateLinks && paginateLinks.totalPages != 0) ? <Paginator paginateLinks={paginateLinks} /> : ''}
                      </div>
                      {(paginateLinks.isLastPage || paginateLinks.totalPages === 0) && <ImmersionFaciliteeCard />}
                    </div>
                    )
                  }
                </div>
              </div>
            </div>
          </div>

          {/* Colonne de la carte */}
          {!isMobile() && (
            <div className="col-5 map-wrapper fr-mx-0 fr-px-0">
              <div className="map-sticky-container">
                {/* Légende */}
                <div className="fr-p-1w" style={{ background: '#fff', borderBottom: '1px solid #ddd', display: 'flex', alignItems: 'center', gap: '1rem', fontSize: '0.875rem' }}>
                  <span style={{ display: 'flex', alignItems: 'center', gap: '0.25rem' }}>
                    <img src={defaultMarker} alt="" style={{ width: 20, height: 20 }} />
                    Offres de stage
                  </span>
                  <label style={{ display: 'flex', alignItems: 'center', gap: '0.25rem', cursor: 'pointer', margin: 0 }}>
                    <input
                      type="checkbox"
                      checked={showBoardingHouses}
                      onChange={() => setShowBoardingHouses(!showBoardingHouses)}
                    />
                    <img src={boardingHouseMarker} alt="" style={{ width: 20, height: 20 }} />
                    Internats
                  </label>
                </div>
                <MapContainer
                  center={center}
                  zoom={6}
                  scrollWheelZoom={false}
                >
                  <TileLayer
                    url="https://{s}.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png"
                    attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
                  />
                  <MarkerClusterGroup>
                    {
                      internshipOffers.length ? (
                        internshipOffers.map((internshipOffer) => (
                          <Marker
                            icon={
                              internshipOffer.id === selectedOffer ? pointerIcon : defaultPointerIcon
                            }
                            position={[internshipOffer.lat, internshipOffer.lon]}
                            key={internshipOffer.id}
                          >
                            <Popup className='popup-custom'>
                              <a href={internshipOffer.link}>
                                <div className="img">
                                  <img className="fr-responsive-img" src={internshipOffer.image} alt="image"></img>
                                </div>
                                <div className="content fr-p-2w">
                                  <p className="fr-card__detail">{internshipOffer.employer_name}</p>
                                  <h6 className="title">
                                    {internshipOffer.title}
                                  </h6>
                                </div>
                              </a>
                            </Popup>
                          </Marker>
                        ))
                      ) : ('')
                    }
                  </MarkerClusterGroup>
                  {/* Boarding house markers - outside cluster group */}
                  {showBoardingHouses && boardingHouses.map((bh) => (
                    <Marker
                      icon={boardingHouseIcon}
                      position={[bh.lat, bh.lon]}
                      key={`bh-${bh.id}`}
                    >
                      <Popup className='popup-custom'>
                        <div className="content fr-p-2w">
                          <p className="fr-card__detail">Internat</p>
                          <h5 className="title" style={{fontSize: '1.375rem', lineHeight: '1.75rem', marginBottom: '0.25rem'}}>{bh.name}</h5>
                          <p className="fr-card__detail fr-mt-1w">
                            Peut proposer jusqu'à {bh.available_places} place{bh.available_places > 1 ? 's' : ''} {bh.reference_date ? `au ${bh.reference_date}` : ''}
                          </p>
                          {bh.contact_phone && (
                            <p className="fr-card__detail">Tél : {bh.contact_phone}</p>
                          )}
                          {bh.contact_email && (
                            <p className="fr-card__detail">Email : {bh.contact_email}</p>
                          )}
                        </div>
                      </Popup>
                    </Marker>
                  ))}
                  <ClickMap
                    internshipOffers={internshipOffers}
                    boardingHouses={boardingHouses}
                    showBoardingHouses={showBoardingHouses}
                    recenterMap={newDataFetched}
                  />
                </MapContainer>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default InternshipOfferResults;
