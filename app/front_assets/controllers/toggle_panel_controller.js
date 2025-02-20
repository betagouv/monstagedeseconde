import { Controller } from "stimulus";
import { toggleContainer } from "../utils/dom";

// This controller is supposed to be generic , reusable

export default class extends Controller {
  static targets = ["panel"];
  static values = {
    on: Boolean,
  };

  onToggle(e) {
    e.preventDefault();
    e.stopPropagation();
    this.onValue = !this.onValue;
    toggleContainer(this.panelTarget, this.onValue);
  }

  connect() {
    console.log("panel connected");
    toggleContainer(this.panelTarget, this.onValue);
  }
}
