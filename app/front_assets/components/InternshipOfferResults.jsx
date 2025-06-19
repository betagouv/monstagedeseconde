import React, { useEffect, useState } from 'react';
import { MapContainer, TileLayer, useMap, Marker, Popup } from 'react-leaflet';
import MarkerClusterGroup from 'react-leaflet-cluster';

import activeMarker from '../images/active_pin.svg';
import defaultMarker from '../images/default_pin.svg';
import InternshipOfferCard from './InternshipOfferCard';
import CardLoader from './CardLoader';
import Paginator from './search_internship_offer/Paginator';
import TitleLoader from './TitleLoader';
import { endpoints } from '../utils/api';
import { isMobile } from '../utils/responsive';
import FlashMessage from './FlashMessage';
import CityInput from './search_internship_offer/CityInput';
import GradeInput from './search_internship_offer/GradeInput';
import WeekInput from './search_internship_offer/WeekInput';
import ImmersionFaciliteeCard from './ImmersionFaciliteeCard';

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

const InternshipOfferResults = ({
    searchParams,
    preselectedWeeksList,
    schoolWeeksList,
    secondeWeekIds
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
  const [notify, setNotify] = useState(false);
  const [notificationMessage, setNotificationMessage] = useState('');
  const [params, setParams] = useState(searchParams);
  const [gradeId, setGradeId] = useState(searchParams.grade_id);

  useEffect(() => {
    fetchtInternshipOffers();
  }, [params]);

  const ClickMap = ({ internshipOffers, recenterMap }) => {
    if (isMobile()) {return null };

    if (internshipOffers.length && recenterMap) {
      const map = useMap();
      const bounds = internshipOffers.map((internshipOffer) => [
        internshipOffer.lat,
        internshipOffer.lon,
      ]);
      map.fitBounds(bounds);
      // L.tileLayer.provider('CartoDB.Positron').addTo(map); MAP STYLE
    }

    setTimeout(() => setNewDataFetched(false), 100);
    return null;
  };

  const handleSubmit = (formData) => {
    console.log('formData: ', formData);
    const searchParams = {
      city: formData.city || '',
      latitude: formData.latitude || '',
      longitude: formData.longitude || '',
      radius: formData.radius || '30',
      grade_id: formData.grade_id || '',
      week_ids: formData.week_ids || [],
    };
    setParams(searchParams);
  };

  const handleMouseOver = (data) => {
    setSelectedOffer(data);
  };

  const handleMouseOut = () => {
    // setSelectedOffer(null);
  };

  // const getSectorsSelected = () => {
  //   const sectors = [];
  //   var clist = document.getElementsByClassName("checkbox-sector");
  //   for (var i = 0; i < clist.length; ++i) {
  //     if (clist[i].checked) {
  //       sectors.push(clist[i].getAttribute('data-sector-id'));
  //     };
  //   };
  //   setSelectedSectors(sectors);
  //   return sectors;
  // }

  const fetchtInternshipOffers = () => {
    setIsLoading(true);
    $.ajax({ type: 'GET', url: endpoints['searchInternshipOffers'](), data: params })
      .done(fetchDone)
      .fail(fetchFail);
  };

  // const updateSectors = () => {
  //   if (!isMobile()) {
  //     document.getElementById("fr-modal-filter").classList.remove("fr-modal--opened");
  //     document.getElementById("filter-sectors-button").setAttribute('data-fr-opened', false);
  //   }
  //   const newParams = { ...params, page: 1, sector_ids: getSectorsSelected() };
  //   setParams(newParams);
  // };

  const fetchDone = (result) => {
    setInternshipOffers(result['internshipOffers']);
    setPaginateLinks(result['pageLinks']);
    setInternshipOffersSeats(result['seats']);

    console.log('result: ', result);
    // setIsSuggestion(result['isSuggestion']);

    setIsLoading(false);
    setNewDataFetched(true);

    // if (internshipOffers.length) {
    //   resizingMap
    // }
    return true
  };

  const fetchFail = (xhr, textStatus) => {
    if (textStatus === 'abort') {
      return;
    }
    // setRequestError('Une erreur est survenue, veuillez ré-essayer plus tard.');
  };

  // const clearSectors = () => {
  //   setShowSectors(false);
  //   var checkboxes = document.getElementsByClassName("checkbox-sector");
  //   for (var checkbox of checkboxes) {
  //     checkbox.checked = false;
  //   }
  // };

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
        <form onSubmit={handleSubmit} id="desktop_internship_offers_index_search_form">
          <div className="row fr-py-4w">
            <div className="col-12">
              <div className="d-flex">
                <div className="fr-px-2w flex-fill align-self-end ">
                  <CityInput
                    city={searchParams.city}
                    latitude={searchParams.latitude}
                    longitude={searchParams.longitude}
                    radius={searchParams.radius}
                    whiteBg="false"
                  />
                </div>
                <div className="fr-px-2w flex-fill align-self-end">
                  <GradeInput
                    setGradeId={setGradeId}
                    gradeId={gradeId}
                    whiteBackground="true"
                  />
                </div>
                <div className="fr-px-2w flex-fill align-self-end">
                  <WeekInput
                    preselectedWeeksList={preselectedWeeksList}
                    schoolWeeksList={schoolWeeksList}
                    studentGradeId={searchParams.grade_id}
                    gradeId={gradeId}
                    setGradeId={setGradeId}
                    whiteBg="false"
                  />
                </div>
                <div className="flex-shrink-1 align-self-end">
                  <button type="submit" className="fr-btn fr-btn--icon-left fr-icon-search-line">Rechercher</button>
                </div>
              </div>
            </div>
          </div>
        </form>
      </div>
       <div className="results-container search-offer-bloc">
      {notify && <FlashMessage message={notificationMessage} display={notify} hideNotification={hideNotification} />}
      <div className="row fr-mx-0 fr-px-0">
        <div className={`${isMobile() ? 'col-12 px-1w' : 'col-7 px-0'}`}>

          <div className="scrollable-content d-flex justify-content-end">
            <div className="results-col fr-mt-2w fr-mx-1w">
              <div className="row fr-py-2w mx-0 ">
                <div className="col-12 px-0">
                  {
                      isLoading ? (
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
                    { !isLoading && (internshipOffersSeats == 0) &&
                      (<p>Aucune offre répondant à vos critères n'est disponible.<br/>Vous pouvez modifier vos filtres et relancer votre recherche.</p>)
                    }
                  </div>
                  {/* {
                    !isMobile() && (
                    <div className="col-4 text-right px-0">
                      <button className="fr-btn fr-btn--secondary fr-icon-filter-line fr-btn--icon-left" data-fr-opened="false" aria-controls="fr-modal-filter" id="filter-sectors-button">
                        Secteur d'activité
                        {
                          selectedSectors.length > 0 ? (
                            <p className="fr-badge fr-badge--success fr-badge--no-icon fr-m-1w">{selectedSectors.length}</p>
                          ) : ''
                        }
                      </button>
                    </div>
                    )
                  } */}
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
                            {
                            internshipOffers.map((internshipOffer, i) => (
                              <InternshipOfferCard
                                internshipOffer={internshipOffer}
                                key={internshipOffer.id}
                                index={i}
                                handleMouseOut={handleMouseOut}
                                handleMouseOver={(value) => {handleMouseOver(value)}}
                                sendNotification={(message) => {sendNotification(message)}}
                                />
                            ))
                          }
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
                  <ClickMap internshipOffers={internshipOffers} recenterMap={newDataFetched} />
                </MapContainer>
              </div>
            </div>
          )}
        </div>

        {/* {
          !isMobile() &&
          (
            <FilterModal
            sectors={sectors}
            updateSectors={updateSectors}
            clearSectors={clearSectors}
            selectedSectors={selectedSectors}
            />
          )
        } */}
      </div>
    </div>
  );
};

export default InternshipOfferResults;