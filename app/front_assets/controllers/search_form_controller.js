import { Controller } from "stimulus";
import { toggleContainers } from "../utils/dom";
import { on } from "hammerjs";

export default class extends Controller {
  static targets = ["grade"];

  // onChangeGrade(event) {
  //   if (this.gradeTarget.value == "1") {
  //     this.show3emeOnly(false);
  //   } else if (this.gradeTarget.value == "2" || this.gradeTarget.value == "3") {
  //     this.show3emeOnly(true);
  //   } else {
  //     toggleContainers(this.allElements(), true);
  //   }
  // }
  
  connect() {
    // this.onChangeGrade();
  }
  // Private
  allElements = () => document.querySelectorAll(".month-score, .month-title");
  juneElements = () => document.querySelectorAll(".month-score.Juin, .month-title.Juin");
  show3emeOnly(value) {
    toggleContainers(this.allElements(), value);
    toggleContainers(this.juneElements(), !value);
  }

}
