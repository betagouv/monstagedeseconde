import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "counter", "error"]
  static values = { max: Number }

  connect() {
    this.updateCounter();
  }

  updateCounter() {
    const maxValue = this.maxValue;

    const currentLength = this.inputTarget.value.length
    this.counterTarget.textContent = `${currentLength}/${this.maxValue} caractères`
    
    if (currentLength > this.maxValue - 1) {
      this.errorTarget.classList.remove('d-none')
    } else {
      this.errorTarget.classList.add('d-none')
    }
  }
}