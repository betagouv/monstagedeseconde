import $ from 'jquery';
import { Controller } from 'stimulus';
import { showElement, hideElement } from '../utils/dom';

export default class extends Controller {
  static targets = ['containerForm', 'containerShowFormLink', 'weekSelect', 'weekIds', 'periodSelect'];

  showForm(event) {
    showElement($(this.containerFormTarget));
    hideElement($(this.containerShowFormLinkTarget));
  }

  hideForm(event) {
    hideElement($(this.containerFormTarget));
    showElement($(this.containerShowFormLinkTarget));
  }

  updateWeekId(event) {
    const selectedValue = $(this.weekSelectTarget).val();
    if (selectedValue) {
      $(this.weekIdsTarget).attr('name', 'internship_application[week_ids][]').val(selectedValue);
    } else {
      $(this.weekIdsTarget).val('');
    }
  }

  updatePeriod(event) {
    $(this.weekIdsTarget).val($(this.periodSelectTarget).val());
  }

  connect() {
    if (window.location.hash === '#internship-application-form') {
      this.showForm();
      window.location.hash = '#internship-application-form';
    }
  }
}
