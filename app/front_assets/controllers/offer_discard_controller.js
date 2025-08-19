import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = [
    'discardReason',
    'softDeleteBlock',
    'unpublishBlock'
  ];


  onChange(event) {
    const reason =  (event.target.value === "no_longer_needed") ? "unpublish" : "softDelete";
    if (reason === "unpublish"){
      this.unpublishBlockTarget.classList.remove('fr-hidden');
      this.softDeleteBlockTarget.classList.add('fr-hidden');
    } else {
      this.unpublishBlockTarget.classList.add('fr-hidden');
      this.softDeleteBlockTarget.classList.remove('fr-hidden');
    }
  }
}