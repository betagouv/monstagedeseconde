import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = [
    'generalCta',
    'signingButton',
    'addCheckBox',
    'generalCtaSelectBox',
  ];

  static values = {
    userType: String,
    counter: Number,
    maxCounter: Number,
    multi: Boolean,
  };

  connect() {
    this.addCheckBoxTargets.forEach(element => {
      element.checked = false;
      if (this.isReadyToSign(element)) {
        this.enable(element);
        this.maxCounterValue++;
      } else { this.disable(element) }
    });
    this.repaintGeneralCta();
  }

  toggle(event) {
    this.commonToggle(event, this.withCheckbox.bind(this));
  }

  toggleFromButton(event) {
    this.commonToggle(event, this.withButton.bind(this));
  }

  toggleSignThemAll(event) {
    const {target} = event;
    if (target.checked) {
      this.addCheckBoxTargets.forEach((element) => {
        if (this.isReadyToSign(element) && (!element.checked)) {
          element.checked = true;
          this.addToList(element.getAttribute('data-group-signing-id-param'));
        }
      });
    } else {
      this.addCheckBoxTargets.forEach((element) => {
        if (this.isReadyToSign(element) && (element.checked)) {
          element.checked = false;
          this.removeFromList(element.getAttribute('data-group-signing-id-param'));
        }
      });
    }
    this.repaintGeneralCta();
  }

  // private functions

  commonToggle(event, fnRef) {
    const agreementId = event.params.id;
    this.addCheckBoxTargets.forEach((element) => {
      if (element.getAttribute('data-group-signing-id-param') == agreementId) {
        fnRef(element, agreementId);
      }
    });
    this.repaintGeneralCta(event);
    this.updateParamsSignaturesUrl();
  }

  withCheckbox(element, agreementId) {
    (element.checked) ? this.addToList(agreementId) : this.removeFromList(agreementId);
  }

  withButton(element, agreementId) {
    if (element.getAttribute('data-group-signing-id-param') == agreementId) {
      if (element.checked) { //let's uncheck it
        element.checked = false
        this.removeFromList(agreementId);
      } else {
        element.checked = true;
        this.addToList(agreementId);
      }
    }
  }

  addToList(agreementId) {
    this.addCounter(1);
    this.signingButtonsAction(agreementId, this.disable);
  }

  removeFromList(agreementId) {
    this.addCounter(-1);
    this.signingButtonsAction(agreementId, this.enable);
  }

  // function to check all the checkboxes checked and add to the general cta a array of ids to the url
  updateParamsSignaturesUrl() {
    const ids = this.addCheckBoxTargets
      .filter((element) => element.checked)
      .map((element) => element.getAttribute('data-group-signing-id-param'));
    const form = this.generalCtaTarget.closest('form');
    const baseUrl = form.getAttribute('action');
    const newUrl = baseUrl.split('?')[0] + '?ids=' + ids.join(',');
    form.setAttribute('action', newUrl);
    // multi broadcasts event to update its cta url
    if (this.multiValue) {
      const payload = { detail: { url: newUrl, counter: this.counterValue } };
      const customEvent = new CustomEvent('ids-to-sign', payload);
      document.dispatchEvent(customEvent);
    }
  }

  checkAllCheckboxes() {
    this.addCheckBoxTargets.forEach((element) => {
      if (element.checked) {
        this.addToList(element.getAttribute('data-group-signing-id-param'));
      }
    });
  }

  signingButtonsAction(agreementId, fn) {
    this.signingButtonTargets.forEach((element) => {
      if (element.getAttribute('data-group-signing-id-param') == agreementId) {
        fn(element);
      }
    });
  }

  repaintGeneralCta() {
    const target = this.generalCtaTarget;
    (this.counterValue === 0) ? this.disable(target) : this.enable(target)

    //paintButtonLabel
    const extraHTML = (this.counterValue > 1) ? " en groupe (" + this.counterValue + ")" : '';


    let buttonLabel = `Signer${extraHTML}`;
    if (this.userTypeValue !== 'Users::SchoolManagement' && this.multiValue) {
      buttonLabel = `Faire signer${extraHTML}`;
    }
    this.generalCtaTarget.innerHTML = buttonLabel;
    const allChecked = this.counterValue === this.maxCounterValue && this.counterValue > 0
    this.generalCtaSelectBoxTarget.checked = allChecked;
  }

  disable(el) { el.setAttribute('disabled', 'disabled'); }

  isReadyToSign(el) { return el.getAttribute('data-group-signing-signed-param') === 'readyToSign' }

  enable(el) { el.removeAttribute('disabled'); }

  addCounter(val) { this.counterValue += val }
}