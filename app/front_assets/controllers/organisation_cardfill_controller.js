import { Controller } from 'stimulus';
import { EVENT_LIST } from '../utils/events';

export default class extends Controller {
  static targets = [
    'weeksInput',
    'weeksOutput',
    'sectorInput',
    'sectorOutput',
    'cityInput',
    'cityOutput',
    'zipcodeInput',
    'zipcodeOutput',
    'employerNameInput',
    'employerNameOutput',
  ];

  // static values = {
  //   fieldName: String
  // }

  cityChanged(event) {
    this.cityOutputTarget.textContent = event.detail.city;
  }
  zipcodeChanged(event) {
    this.zipcodeOutputTarget.textContent = event.detail.zipcode;
  }
  sectorChanged(event) {
    this.sectorOutputTarget.textContent = event.detail.sector;
  }

  connect() {
    document.addEventListener(EVENT_LIST.ZIPCODE_CHANGED,this.zipcodeChanged.bind(this));
    document.addEventListener(EVENT_LIST.CITY_CHANGED, this.cityChanged.bind(this));
    document.addEventListener(EVENT_LIST.SECTOR_CHANGED, this.sectorChanged.bind(this));
  }
}