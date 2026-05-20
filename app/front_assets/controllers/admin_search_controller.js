import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input"];
  static values = {
    minLength: { type: Number, default: 3 },
    debounce:  { type: Number, default: 250 },
  };

  connect() {
    this.timer = null;
  }

  search() {
    clearTimeout(this.timer);
    const value = this.inputTarget.value.trim();
    if (value.length < this.minLengthValue) return;
    this.timer = setTimeout(() => {
      this.element.requestSubmit();
    }, this.debounceValue);
  }

  disconnect() {
    clearTimeout(this.timer);
  }
}
