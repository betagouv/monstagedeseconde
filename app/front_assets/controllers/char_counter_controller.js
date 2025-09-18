import { Controller } from "stimulus";
import { toggleContainer } from "../utils/dom";

export default class extends Controller {
  static targets = ["field", "alertMessage", "currentCount"];

  static values = {
    maxLength: Number,
  };

  updateCharCount() {
    const currentLength = this.fieldTarget.value.length;
    this.displayCounter(currentLength);
    this.displayAlert(this.isAlert());
  }

  isAlert() {
    const currentLength = this.fieldTarget.value.length;
    return (
      currentLength > this.maxLengthValue
    );
  }

  displayCounter(num) {
    this.currentCountTarget.innerText = `${num} / ${this.maxLengthValue}`;
  }

  displayAlert(show) {
    toggleContainer(this.alertMessageTarget, show);
  }

  connect(){
    this.fieldTarget.addEventListener("input", () => this.updateCharCount());
  }
}
