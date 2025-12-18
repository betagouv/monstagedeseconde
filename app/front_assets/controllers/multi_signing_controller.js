import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['ids', 'counter'];

  counter = 0;

  getCounter() {
    return this.counter;
  }

  setCounter(value) {
    this.counter = value;
    this.counterTarget.textContent = this.counter;
  }

  connect() {
    document.addEventListener('ids-to-sign', this.updateCtaUrl.bind(this));
  }

  updateCtaUrl(event) {
    const { url, counter } = event.detail;
    // eslint-disable-next-line prefer-destructuring
    this.idsTarget.value = url.split('ids=')[1];
    if (counter !== undefined) {
      if (counter !== 1) {
        this.counterTarget.textContent = ` de ${counter} élève(s)`;
      } else {
        this.counterTarget.textContent = " d'un élève";
      }
    }
  }

  disconnect() {
    document.removeEventListener('ids-to-sign', this.updateCtaUrl.bind(this));
  }
}
