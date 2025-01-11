import { Controller } from "@hotwired/stimulus";
import { toggleContainer } from "../utils/dom";
export default class extends Controller {
  static targets = [
    "gradeCollege",
    "grade2e",
    "alertContainer",
    "troisiemeContainer",
    "secondeContainer",
  ];

  gradeCollegeTargetConnected() {
    this.onClick();
  }

  grade2eTargetConnected() {
    this.onClick();
  }

  onClick(event) {
    const gradeCollegeChecked = this.gradeCollegeTarget.checked;
    const grade2eChecked = this.grade2eTarget.checked;
    const noGradesChecked = !grade2eChecked && !gradeCollegeChecked;

    toggleContainer(this.troisiemeContainerTarget, gradeCollegeChecked);
    toggleContainer(this.secondeContainerTarget, grade2eChecked);
    // At least One Choice Between 3e/4e and 2e
    if (event =! undefined) {
      toggleContainer(this.alertContainerTarget, noGradesChecked);
    }
  }
}
