import { Controller } from "@hotwired/stimulus";
import { toggleContainer } from "../utils/dom";
export default class extends Controller {
  static targets = [
    'gradeCollege',
    'grade2e',
    'alertContainer',
    'troisiemeContainer',
    'secondeContainer'];

  connect() {}

  onClick(_event) {
    const gradeCollegeChecked = this.gradeCollegeTarget.checked;
    const grade2eChecked      = this.grade2eTarget.checked;
    const alertClassList      = this.alertContainerTarget.classList;
    const troisiemeClassList  = this.troisiemeContainerTarget.classList;
    const secondeClassList    = this.secondeContainerTarget.classList;
    const gradesAllUnchecked  = !grade2eChecked && !gradeCollegeChecked;

    toggleContainer(troisiemeClassList, gradeCollegeChecked);
    toggleContainer(secondeClassList, grade2eChecked);
    // At least One Choice Between 3e/4e and 2e
    toggleContainer(alertClassList, gradesAllUnchecked);
  }
}