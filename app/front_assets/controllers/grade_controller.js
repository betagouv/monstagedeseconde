import { Controller } from "@hotwired/stimulus";
import { toggleContainer } from "../utils/dom";
export default class extends Controller {
  static targets = [
    'grade3e4e',
    'grade2e',
    'alertContainer',
    'troisiemeContainer',
    'secondeContainer'];

  connect() {}

  onClick(_event) {
    const grade3e4eChecked   = this.grade3e4eTarget.checked;
    const grade2eChecked     = this.grade2eTarget.checked;
    const alertClassList     = this.alertContainerTarget.classList;
    const troisiemeClassList = this.troisiemeContainerTarget.classList;
    const secondeClassList   = this.secondeContainerTarget.classList;
    const gradesAllUnchecked = !grade2eChecked && !grade3e4eChecked;

    toggleContainer(troisiemeClassList, grade3e4eChecked);
    toggleContainer(secondeClassList, grade2eChecked);
    // At least One Choice Between 3e/4e and 2e
    toggleContainer(alertClassList, gradesAllUnchecked);
  }
}