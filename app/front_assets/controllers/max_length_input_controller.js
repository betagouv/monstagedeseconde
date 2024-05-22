import $ from 'jquery';
import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['maxLengthMessage', 'group', 'charCount'];

  static values = {
    limit: Number
  }


  groupTargetConnected() {
    const inputField = this.groupTarget.children[0].children[1];
    const limit = this.limitValue;

    inputField.addEventListener('input', _e => {
      const stringLength = inputField.value.length;
      this.charCountTarget.innerText = `${stringLength} caractères / ${limit}`;

      if (stringLength >= limit) {
        this.maxLengthMessageTarget.classList.remove('d-none');
      } else {
        this.maxLengthMessageTarget.classList.add('d-none');
      }
    });
  }
}
