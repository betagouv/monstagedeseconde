import { Controller } from 'stimulus';
import $ from 'jquery';

const DELAY_BEFORE_REMOVAL = 10000

export default class extends Controller {
  static targets = ['root']

  removeAlert() {
    $(this.rootTarget).slideUp()
  }

  connect(){
    // Auto-dismiss the flash after a delay on every device (desktop included).
    // Previously this only ran on mobile, so the success toast stayed forever
    // on desktop (see MGF-1666).
    this.timeout = setTimeout(this.removeAlert.bind(this),
                              DELAY_BEFORE_REMOVAL)
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout);
    }
  }
}
