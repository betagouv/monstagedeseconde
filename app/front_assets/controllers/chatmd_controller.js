import { Controller } from "stimulus";

// Floating bubble opening the ChatMD assistant.
// The iframe is only loaded on first opening.
export default class extends Controller {
  static targets = ["button", "box", "iframe"];

  toggle() {
    const opening = this.boxTarget.hidden;
    if (opening && !this.iframeTarget.getAttribute("src")) {
      this.iframeTarget.setAttribute("src", this.iframeTarget.dataset.src);
    }
    this.boxTarget.hidden = !opening;
    this.buttonTarget.setAttribute("aria-expanded", opening.toString());
  }
}
