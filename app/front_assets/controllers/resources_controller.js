import $ from 'jquery';
import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ["contentDiv", "levelButton", "categoryButton"]

  connect() {
    this.contentDivTargets[0].style.display = 'block';
  }

  selectLevel(event) {
    event.preventDefault();

    this.levelButtonTargets.forEach((button) => {
      button.removeAttribute('aria-current');
    });

    event.currentTarget.setAttribute('aria-current', 'true');
  }

  showContent(event) {
    event.preventDefault();
    const index = event.currentTarget.dataset.index;

    this.categoryButtonTargets.forEach((button) => {
      button.removeAttribute('aria-current');
    });

    event.currentTarget.setAttribute('aria-current', 'true');

    this.contentDivTargets.forEach((div, idx) => {
      div.style.display = 'none';
    });

    this.contentDivTargets[index].style.display = 'block';
  }
}
