import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "counter", "error", "minError"]
  static values = { max: Number, min: Number }

  connect() {
    this.updateCounter();
  }

  updateCounter() {
    const currentLength = this.inputTarget.value.length
    this.counterTarget.textContent = `${currentLength}/${this.maxValue} caractères`

    if (currentLength > this.maxValue - 1) {
      this.errorTarget.classList.remove('d-none')
    } else {
      this.errorTarget.classList.add('d-none')
    }
  }

  // MGF-1666: the field stays optional, but once the user typed something it
  // must contain at least `min` characters. Validated on blur.
  validateMin() {
    if (!this.hasMinErrorTarget || !this.hasMinValue || this.minValue <= 0) return;

    const length = this.inputTarget.value.trim().length;
    const tooShort = length > 0 && length < this.minValue;
    this.minErrorTarget.classList.toggle('fr-hidden', !tooShort);
    this.inputTarget.classList.toggle('fr-input--error', tooShort);
  }
}