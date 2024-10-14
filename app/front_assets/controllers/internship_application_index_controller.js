import { Controller } from '@hotwired/stimulus';
import { toggleElement, hideElement, showElement } from '../utils/dom';

export default class extends Controller {
  static targets = ['bulkActionButton', 'selectedCount', 'dropdownMenu', 'acceptationModal', 'rejectionModal'];

  connect() {
  }

  toggleBulkActionButton() {
    if (!this.hasBulkActionButtonTarget) {
      return;
    }

    const checkedBoxes = this.element.querySelectorAll('input[type="checkbox"]:checked');
    const checkedCount = checkedBoxes.length;

    if (checkedCount > 1) {
      this.bulkActionButtonTarget.classList.remove('fr-hidden');
      const buttonText = `Action groupée (${checkedCount}) <i class="fr-icon-arrow-down-s-line fr-icon--right" aria-hidden="true"></i>`;
      this.bulkActionButtonTarget.innerHTML = buttonText;
      // update all selectedCounts
      this.selectedCountTargets.forEach(target => {
        target.textContent = checkedCount;
      });
      this.updateIdsField();
    } else {
      this.bulkActionButtonTarget.classList.add('fr-hidden');
    }
  }

  openAcceptationModal(event) {
    event.preventDefault();
    this.acceptationModalTarget.classList.add('fr-modal--opened');
  }

  openRejectionModal(event) {
    event.preventDefault();
    this.rejectionModalTarget.classList.add('fr-modal--opened');
  }

  closeAcceptationModal(event) {
    event.preventDefault();
    this.acceptationModalTarget.classList.remove('fr-modal--opened');
  }

  closeRejectionModal(event) {
    event.preventDefault();
    this.rejectionModalTarget.classList.remove('fr-modal--opened');
  }

  updateIdsField() {
    // updae all ids field form in all modals not just in acceptationModal
    const ids = Array.from(this.element.querySelectorAll('input[type="checkbox"]:checked')).map((checkbox) => checkbox.value).join(',');
    this.acceptationModalTarget.querySelector('input[name="ids"]').value = ids;
    this.rejectionModalTarget.querySelector('input[name="ids"]').value = ids;
  }

  toggleDropdown(event) {
    event.preventDefault();

    if (!this.hasDropdownMenuTarget) {
      return;
    }

    const isExpanded = this.bulkActionButtonTarget.getAttribute('aria-expanded') === 'true';
    this.bulkActionButtonTarget.setAttribute('aria-expanded', (!isExpanded).toString());
    this.dropdownMenuTarget.classList.toggle('fr-collapse--expanded');
    this.dropdownMenuTarget.classList.toggle('is-visible');
    const dropdownMenu = document.getElementById('dropdownMenu');
    const dropdown = this.element.querySelector('.fr-dropdown');

    if (isExpanded) {
      dropdownMenu.classList.add('fr-hidden');
      dropdown.classList.remove('min-height-100');
    } else {
      dropdownMenu.classList.remove('fr-hidden');
      dropdown.classList.add('min-height-100');
    }

  }
}
