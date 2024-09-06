// used to connect react/stimulus
// listen to event with `attach` on stimulus.connect
//                      (and don't forget to `detach` on stimulus.disconnect)
// beware, keep a reference to the event listener to detail it nicely

// keep list of event formatted here
export const EVENT_LIST = {
  COORDINATES_CHANGED: 'coordinates-changed',
  ZIPCODE_CHANGED: 'zipcode-changed',
  CITY_CHANGED: 'city-changed',
  SECTOR_CHANGED: 'sector-changed',
  OFFER_TITLE_CHANGED: 'offer-title-changed',
  EMPLOYER_NAME_CHANGED: 'employer-name-changed',
  WEEKS_COUNT_CHANGED: 'weeks-count-changed',
};

// keep event builder here
export const newCoordinatesChanged = ({ latitude, longitude }) => {
  return new CustomEvent(EVENT_LIST.COORDINATES_CHANGED, {
    detail: { latitude, longitude },
  });
};

export const zipcodeChanged = ({ zipcode }) => {
  return new CustomEvent(EVENT_LIST.ZIPCODE_CHANGED, {
    detail: { zipcode },
  });
};

export const cityChanged = ({ city }) => {
  return new CustomEvent(EVENT_LIST.CITY_CHANGED, {
    detail: { city },
  });
};

export const sectorChanged = ({ sector }) => {
  return new CustomEvent(EVENT_LIST.SECTOR_CHANGED, {
    detail: { sector },
  });
};

export const offerTitleChanged = ({ offerTitle }) => {
  return new CustomEvent(EVENT_LIST.OFFER_TITLE_CHANGED, {
    detail: { offerTitle },
  });
};

export const employerName = ({ employerName }) => {
  return new CustomEvent(EVENT_LIST.EMPLOYER_NAME_CHANGED, {
    detail: { employerName },
  });
};

export const weeksCount = ({ weeksCount }) => {
  return new CustomEvent(EVENT_LIST.WEEKS_COUNT_CHANGED, {
    detail: { weeksCount },
  });
};

// use default DOM event model
export const attach = (eventName, handler) => document.addEventListener(eventName, handler);
export const detach = (eventName, handler) => document.removeEventListener(eventName, handler);
export const broadcast = (event) => document.dispatchEvent(event);
