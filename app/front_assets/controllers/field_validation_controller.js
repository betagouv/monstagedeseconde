import { Controller } from 'stimulus';

// Reusable inline validation for DSFR text inputs / textareas.
//
// Validates the field when it loses focus (blur) and again when the parent
// form is submitted. On error it toggles the DSFR error classes on the
// `.fr-input-group` (the controller host) and reveals the `.fr-error-text`
// message. It NEVER mutates the field value, so the form is never reset.
//
// Wiring (see app/views/inputs/_dsfr_input_field.html.slim, opt-in via the
// `validate:` local):
//   .fr-input-group data-controller="field-validation"
//                   data-field-validation-required-value="true"
//                   data-field-validation-required-message-value="…"
//                   data-field-validation-min-length-value="10"
//     input data-field-validation-target="field"
//           data-action="blur->field-validation#validate"
//     p.fr-error-text.fr-hidden data-field-validation-target="errorText"
export default class extends Controller {
  static targets = ['field', 'errorText'];

  static values = {
    required: Boolean,
    minLength: Number,
    min: Number,
    pattern: String,
    requiredMessage: String,
    minLengthMessage: String,
    minMessage: String,
    patternMessage: String,
  };

  connect() {
    this.form = this.element.closest('form');
    if (this.form) {
      this.boundValidateOnSubmit = this.validateOnSubmit.bind(this);
      this.form.addEventListener('submit', this.boundValidateOnSubmit);
    }
  }

  disconnect() {
    if (this.form && this.boundValidateOnSubmit) {
      this.form.removeEventListener('submit', this.boundValidateOnSubmit);
    }
  }

  // A field inside a collapsed block (d-none / fr-hidden) is not validated.
  isVisible() {
    if (!this.hasFieldTarget) return false;
    const field = this.fieldTarget;
    return field.offsetParent !== null && !field.closest('.d-none') && !field.closest('.fr-hidden');
  }

  // Returns the first violated rule's message, or null when the field is valid.
  errorMessage() {
    if (!this.hasFieldTarget) return null;
    const rawValue = this.fieldTarget.value || '';
    const value = rawValue.trim();

    if (this.requiredValue && value.length === 0) {
      return this.requiredMessageValue || 'Ce champ est obligatoire';
    }
    // Optional field left empty is valid.
    if (value.length === 0) return null;

    if (this.hasMinLengthValue && this.minLengthValue > 0 && value.length < this.minLengthValue) {
      return (
        this.minLengthMessageValue || `Veuillez saisir au moins ${this.minLengthValue} caractères`
      );
    }
    if (this.hasMinValue && Number(rawValue) < this.minValue) {
      return this.minMessageValue || `La valeur doit être supérieure ou égale à ${this.minValue}`;
    }
    if (this.patternValue) {
      let regexp;
      try {
        regexp = new RegExp(this.patternValue);
      } catch (e) {
        regexp = null;
      }
      if (regexp && !regexp.test(value)) {
        return this.patternMessageValue || "Le format saisi n'est pas valide";
      }
    }
    return null;
  }

  validate() {
    if (!this.isVisible()) {
      this.clearError();
      return true;
    }
    const message = this.errorMessage();
    if (message) {
      this.showError(message);
      return false;
    }
    this.clearError();
    return true;
  }

  validateOnSubmit(event) {
    if (this.validate()) return;

    event.preventDefault();
    // Focus the first invalid field only (don't fight other controllers).
    if (!document.activeElement || document.activeElement === document.body) {
      this.fieldTarget.focus();
    }
  }

  showError(message) {
    this.element.classList.add('fr-input-group--error');
    this.element.classList.remove('fr-input-group--valid');
    this.fieldTarget.classList.add('fr-input--error');
    this.fieldTarget.classList.remove('fr-input--valid');
    if (this.hasErrorTextTarget) {
      this.errorTextTarget.textContent = message;
      this.errorTextTarget.classList.remove('fr-hidden');
    }
  }

  clearError() {
    this.element.classList.remove('fr-input-group--error');
    this.fieldTarget.classList.remove('fr-input--error');
    if (this.hasErrorTextTarget) {
      this.errorTextTarget.classList.add('fr-hidden');
    }
  }
}
