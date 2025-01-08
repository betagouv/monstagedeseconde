import { Controller } from 'stimulus';
import { weeksCountChanged,
         offerTitleChanged,
         sectorChanged,
         employerNameChanged,
         zipcodeChanged,
         cityChanged,
         broadcast} from '../utils/events';

export default class extends Controller {
  static targets = [
    'weeksInput',
    'sectorInput',
    'offerTitleInput',
    'employerNameInput',
    'zipcodeInput',
    'cityInput',
  ];

  weeksCountChanged(event) {
    if (this.hasWeeksInputTarget) {
      const payload = { weeksCount: this.weeksInputTarget.value };
      broadcast(weeksCountChanged(payload));
    }
  }
  sectorChanged(event) {
    event.preventDefault();
    if (this.hasSectorInputTarget) {
      const payload = { sector: this.sectorInputTarget.selectedOptions[0].innerHTML };
      broadcast(sectorChanged(payload));
    }
  }
  offerTitleChanged(event) {
    event.preventDefault();
    if (this.hasOfferTitleInputTarget) {
      const payload = { offerTitle: this.offerTitleInputTarget.value };
      broadcast(offerTitleChanged(payload));
    }
  }
  employerNameChanged(event) {
    event.preventDefault();
    if (this.hasEmployerNameInputTarget) {
      const payload = { employerName: this.employerNameInputTarget.value };
      broadcast(employerNameChanged(payload));
    }
  }
  cityChanged(event) {
    event.preventDefault();
    if (this.hasCityInputTarget) {
      const payload = { city: this.cityInputTarget.value };
      broadcast(cityChanged(payload));
    }
  }
  zipcodeChanged(event) {
    event.preventDefault();
    if (this.hasZipcodeInputTarget) {
      const payload = { zipcode: this.zipcodeInputTarget.value };
      broadcast(zipcodeChanged(payload));
    }
  }

  connect() { }

  disconnect() { }
}