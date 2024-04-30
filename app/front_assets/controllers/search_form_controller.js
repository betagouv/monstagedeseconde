import { Controller } from 'stimulus';
import { isVisible, hideElement, showElement } from '../utils/dom';

export default class extends Controller {

  static targets = [
    "tabPane", // multiple targets to navigate weeks selection // months
  ];

  showWeekOrMonthSelection(clickEvent) {
    const currentTarget = clickEvent.currentTarget;
    const href = new URL(currentTarget.href);
    const target = href.hash.replace(/#/, '');

    this.tabPaneTargets.map(( element) => {
      const $el = $(element)

      if (element.id == target) {
        showElement($el)
      } else if (isVisible($el)) {
        hideElement($el)
      } else {
        // no op, hidden element stays hidden
      }
    })
    clickEvent.preventDefault();
  }

  connect() {
    const observer = new MutationObserver(removeStyle);
    observer.observe(document.body, { attributes: true, subtree: true, attributeFilter: ['style'] });

    function removeStyle() {
      const tabs = document.querySelector('.fr-tabs');
      if (tabs) {
          tabs.style.removeProperty('--tabs-height');
      }
    }
  }
}
