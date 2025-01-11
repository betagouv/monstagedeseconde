import { Controller } from 'stimulus';
import { EVENT_LIST, attach, detach} from '../utils/events';

export default class extends Controller {
  static targets = [
    'weeksOutput',
    'sectorOutput',
    'offerTitleOutput',
    'employerNameOutput',
    'zipcodeOutput',
    'cityOutput',
  ];

  durationOutputTargetConnected(target){}

  weeksCountChanged(event) {
      this.weeksOutputTarget.textContent = event.detail.weeksCount;
  }
  sectorChanged(event) {
      this.sectorOutputTarget.textContent = event.detail.sector;
  }
  offerTitleChanged(event) {
    this.offerTitleOutputTarget.innerHTML= event.detail.offerTitle;
  }
  employerNameChanged(event) {
      this.employerNameOutputTarget.textContent = event.detail.employerName;
  }
  cityChanged(event) {
      this.cityOutputTarget.textContent = event.detail.city;
  }
  zipcodeChanged(event) {
      this.zipcodeOutputTarget.textContent = event.detail.zipcode;
  }

  connect() {
    attach(EVENT_LIST.WEEKS_COUNT_CHANGED, this.weeksCountChanged.bind(this));
    attach(EVENT_LIST.SECTOR_CHANGED, this.sectorChanged.bind(this));
    attach(EVENT_LIST.OFFER_TITLE_CHANGED, this.offerTitleChanged.bind(this));
    attach(EVENT_LIST.EMPLOYER_NAME_CHANGED, this.employerNameChanged.bind(this));
    attach(EVENT_LIST.CITY_CHANGED, this.cityChanged.bind(this));
    attach(EVENT_LIST.ZIPCODE_CHANGED,this.zipcodeChanged.bind(this));
  }

  disconnect() {
    detach('CustomEvent', EVENT_LIST.WEEKS_COUNT_CHANGED);
    detach('CustomEvent', EVENT_LIST.SECTOR_CHANGED);
    detach('CustomEvent', EVENT_LIST.OFFER_TITLE_CHANGED);
    detach('CustomEvent', EVENT_LIST.EMPLOYER_NAME_CHANGED);
    detach('CustomEvent', EVENT_LIST.CITY_CHANGED);
    detach('CustomEvent', EVENT_LIST.ZIPCODE_CHANGED);
  }
}