import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['maxLengthMessage', 'group', 'charCount', 'minLengthMessage'];

  static values = { limit: Number, minLength: Number };

  groupTargetConnected() {
    const inputField = this.groupTarget.children[0].children[1];
    const limit = this.limitValue;

    inputField.addEventListener('input', () => {
      const stringLength = inputField.value.length;
      this.charCountTarget.innerText = `${stringLength} caractères / ${limit} - minimum ${this.minLengthValue} caractères`;

      if (stringLength >= limit) {
        this.maxLengthMessageTarget.classList.remove('d-none');
      } else {
        this.maxLengthMessageTarget.classList.add('d-none');
      }
      if (!this.hasMinLengthValue) return;

      if (stringLength < this.minLengthValue) {
        this.minLengthMessageTarget.classList.remove('d-none');
      } else {
        this.minLengthMessageTarget.classList.add('d-none');
      }
    });
  }
}
