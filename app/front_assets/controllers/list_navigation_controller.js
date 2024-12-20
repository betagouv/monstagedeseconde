import { Controller } from 'stimulus';
import { isMobile } from '../utils/responsive';
import Hammer from 'hammerjs';
import { Turbo } from "@hotwired/turbo-rails";

export default class extends Controller {
  static values = {
    previousUrl: String,
    nextUrl: String,
  };

  connect() {
    // see: http://hammerjs.github.io/tips/#i-cant-select-my-text-anymore
    delete Hammer.defaults.cssProps.userSelect;

    if (isMobile()) {
      this.hammer = new Hammer(document.body, {});
      if (this.previousUrlValue.length > 0) {
        this.hammer.on('swipeleft', this.previous.bind(this));
      }
      if (this.nextUrlValue.length > 0) {
        this.hammer.on('swiperight', this.next.bind(this));
      }
    }
  }

  previous() {
    const url = this.previousUrlValue;
    Turbo.visit(url);
  }

  next() {
    const url = this.nextUrlValue;
    Turbo.visit(url);
  }

  disconnect() {
    if (isMobile() && this.hammer) {

      this.hammer.destroy();
    }
  }
}
