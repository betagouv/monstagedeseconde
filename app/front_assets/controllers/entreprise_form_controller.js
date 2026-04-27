import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = ['submitButton'];

  connect() {
    this.isStepperNewPage = window.location.pathname.includes('/etapes/entreprise/nouveau');

    if (!this.isStepperNewPage) return;

    this.form = this.element.closest('form');
    if (!this.form) return;

    this.boundValidate = this.validateBeforeSubmit.bind(this);
    this.form.addEventListener('submit', this.boundValidate);
  }

  disconnect() {
    if (this.form && this.boundValidate) {
      this.form.removeEventListener('submit', this.boundValidate);
    }
  }

  validateBeforeSubmit(event) {
    const ministryBlock = document.getElementById('ministry-block');
    const groupChoice = document.getElementById('group-choice');

    if (!ministryBlock || !groupChoice) return;

    const isVisible = !ministryBlock.classList.contains('fr-hidden') &&
                      !ministryBlock.hasAttribute('hidden') &&
                      ministryBlock.offsetParent !== null;

    if (isVisible && !groupChoice.value) {
      event.preventDefault();
      event.stopPropagation();

      groupChoice.classList.add('fr-select--error');

      let errorMsg = ministryBlock.querySelector('.fr-error-text');
      if (!errorMsg) {
        errorMsg = document.createElement('p');
        errorMsg.className = 'fr-error-text';
        errorMsg.id = 'group-choice-error';
        errorMsg.textContent = "Veuillez sélectionner un type d'employeur public";
        groupChoice.parentNode.appendChild(errorMsg);
      }
      errorMsg.classList.remove('fr-hidden');
      groupChoice.focus();
    }
  }

  checkForm() {
    if (!this.isStepperNewPage) return;

    const ministryBlock = document.getElementById('ministry-block');
    const groupChoice = document.getElementById('group-choice');

    if (!ministryBlock || !groupChoice) return;

    // Clear error when user selects a value
    if (groupChoice.value) {
      groupChoice.classList.remove('fr-select--error');
      const errorMsg = ministryBlock.querySelector('.fr-error-text');
      if (errorMsg) {
        errorMsg.classList.add('fr-hidden');
      }
    }
  }
}
