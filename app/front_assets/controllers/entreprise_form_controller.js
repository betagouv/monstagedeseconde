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

  // Le bloc "Type d'employeur public" n'est validé que lorsqu'il est visible
  // (structure publique). Renvoie le couple {block, select} ou null.
  ministryFields() {
    const ministryBlock = document.getElementById('ministry-block');
    const groupChoice = document.getElementById('group-choice');
    if (!ministryBlock || !groupChoice) return null;

    const isVisible =
      !ministryBlock.classList.contains('fr-hidden') &&
      !ministryBlock.hasAttribute('hidden') &&
      ministryBlock.offsetParent !== null;
    if (!isVisible) return null;

    return { ministryBlock, groupChoice };
  }

  showGroupChoiceError({ ministryBlock, groupChoice }) {
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
  }

  clearGroupChoiceError(ministryBlock, groupChoice) {
    groupChoice.classList.remove('fr-select--error');
    const errorMsg = ministryBlock.querySelector('.fr-error-text');
    if (errorMsg) errorMsg.classList.add('fr-hidden');
  }

  // MGF-1666 : valide au blur du select (quand on quitte la saisie sans choisir).
  validateGroupChoice() {
    if (!this.isStepperNewPage) return;

    const fields = this.ministryFields();
    if (!fields) return;

    if (fields.groupChoice.value) {
      this.clearGroupChoiceError(fields.ministryBlock, fields.groupChoice);
    } else {
      this.showGroupChoiceError(fields);
    }
  }

  // Le secteur d'activité (obligatoire côté serveur via belongs_to :sector) n'est
  // validé que lorsque son bloc est visible (révélé après résolution du SIRET),
  // pour le public comme pour le privé.
  sectorSelectEl() {
    return document.querySelector('select.sector_list');
  }

  sectorIsRequired(select) {
    return Boolean(
      select && select.offsetParent !== null && !select.closest('.fr-hidden')
    );
  }

  showSectorError(select) {
    select.classList.add('fr-select--error');

    let errorMsg = select.parentNode.querySelector('#sector-choice-error');
    if (!errorMsg) {
      errorMsg = document.createElement('p');
      errorMsg.className = 'fr-error-text';
      errorMsg.id = 'sector-choice-error';
      errorMsg.textContent = "Veuillez choisir un secteur d'activité pour l'offre de stage";
      select.parentNode.appendChild(errorMsg);
    }
    errorMsg.classList.remove('fr-hidden');
  }

  clearSectorError(select) {
    select.classList.remove('fr-select--error');
    const errorMsg = select.parentNode.querySelector('#sector-choice-error');
    if (errorMsg) errorMsg.classList.add('fr-hidden');
  }

  // MGF-1666 : valide au blur/change du select secteur.
  validateSector() {
    if (!this.isStepperNewPage) return;

    const select = this.sectorSelectEl();
    if (!this.sectorIsRequired(select)) return;

    if (select.value) {
      this.clearSectorError(select);
    } else {
      this.showSectorError(select);
    }
  }

  validateBeforeSubmit(event) {
    let valid = true;
    let firstInvalid = null;

    // Type d'employeur public (uniquement pour les structures publiques).
    const groupFields = this.ministryFields();
    if (groupFields && !groupFields.groupChoice.value) {
      this.showGroupChoiceError(groupFields);
      valid = false;
      firstInvalid = firstInvalid || groupFields.groupChoice;
    }

    // Secteur d'activité (requis dès que le bloc est visible, public ou privé).
    const sector = this.sectorSelectEl();
    if (this.sectorIsRequired(sector) && !sector.value) {
      this.showSectorError(sector);
      valid = false;
      firstInvalid = firstInvalid || sector;
    }

    if (!valid) {
      event.preventDefault();
      event.stopPropagation();
      if (firstInvalid) firstInvalid.focus();
    }
  }

  checkForm() {
    if (!this.isStepperNewPage) return;

    const fields = this.ministryFields();
    if (fields && fields.groupChoice.value) {
      this.clearGroupChoiceError(fields.ministryBlock, fields.groupChoice);
    }

    // Clear sector error as soon as the user selects a value.
    const sector = this.sectorSelectEl();
    if (sector && sector.value) {
      this.clearSectorError(sector);
    }
  }
}
