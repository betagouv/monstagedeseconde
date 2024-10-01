import $ from 'jquery';
import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ["contentDiv"]

  connect() {
    // display the first content-div
    this.contentDivTargets[0].style.display = 'block';
  }

  showContent(event) {
    event.preventDefault();
    const index = event.currentTarget.dataset.index;

    // Hide all content-div
    this.contentDivTargets.forEach((div, idx) => {
      div.style.display = 'none';
    });

    // Display the content-div with the index
    this.contentDivTargets[index].style.display = 'block';
  }
}
