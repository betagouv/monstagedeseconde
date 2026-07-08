import { Controller } from '@hotwired/stimulus';
import { toggleContainer, openDsfrModal } from '../utils/dom';

export default class extends Controller {
  static targets = [
    'gradeCollege',
    'grade2e',
    'alertContainer',
    'troisiemeContainer',
    'secondeContainer',
    'dialogContainer',
    'maxCandidatesSource',
    'maxCandidatesDisplay',
  ];

  static values = { initialGrades: String };

  isTroisiemeForbidden() {
    return this.gradeCollegeTarget.dataset.gradeForbiddenValue === 'true';
  }

  gradeCollegeTargetConnected() {
    this.onClick();
  }

  grade2eTargetConnected() {
    this.onClick();
  }

  isDoubleGradeOffer() {
    return this.gradeCollegeTarget.checked && this.grade2eTarget.checked;
  }

  noGradeOffer() {
    return !this.gradeCollegeTarget.checked && !this.grade2eTarget.checked;
  }

  onClick(event) {
    toggleContainer(this.troisiemeContainerTarget, this.gradeCollegeTarget.checked);
    toggleContainer(this.secondeContainerTarget, this.grade2eTarget.checked);
    // At least One Choice Between 3e/4e and 2e
    if (event !== undefined) {
      toggleContainer(this.alertContainerTarget, this.noGradeOffer());
    }
  }

  onConfirm() {
    if (this.submitting) return;
    this.submitting = true;
    this.element.closest('form').submit();
  }

  // MGF-1666: a planning can't be published without at least one week. Delegates
  // to the select-weeks controller (same element) so a "specific weeks" offer
  // without any checked week is blocked instead of silently created.
  selectWeeksController() {
    return this.application.getControllerForElementAndIdentifier(this.element, 'select-weeks');
  }

  weekSelectionInvalid() {
    const controller = this.selectWeeksController();
    return Boolean(controller && typeof controller.weekSelectionInvalid === 'function' && controller.weekSelectionInvalid());
  }

  // MGF-1666: the publish button is never disabled. Clicking it runs every
  // field-validation island in the form (lunch break, number of students…) so
  // invalid fields turn red. onConfirm submits programmatically and bypasses the
  // form's submit listeners, hence we trigger the validations here. Returns true
  // when all fields are valid.
  validateFields() {
    const form = this.element.closest('form');
    if (!form) return true;

    let allValid = true;
    form.querySelectorAll('[data-controller~="field-validation"]').forEach((el) => {
      const controller = this.application.getControllerForElementAndIdentifier(el, 'field-validation');
      if (controller && typeof controller.validate === 'function' && !controller.validate()) {
        allValid = false;
      }
    });
    return allValid;
  }

  // MGF-1666: les horaires de stage sont obligatoires. Délègue au contrôleur
  // daily-hours (sur un élément imbriqué) qui affiche les selects en rouge.
  dailyHoursController() {
    const el = this.element.querySelector('[data-controller~="daily-hours"]');
    return el ? this.application.getControllerForElementAndIdentifier(el, 'daily-hours') : null;
  }

  validateHours() {
    const controller = this.dailyHoursController();
    if (!controller || typeof controller.validate !== 'function') return true;
    return controller.validate();
  }

  onValidate(event) {
    event.preventDefault();
    event.stopPropagation();

    if (this.submitting) return;

    // Run every validation so all errors show at once; the button stays active.
    let valid = true;

    if (this.noGradeOffer()) {
      toggleContainer(this.alertContainerTarget, true);
      valid = false;
    }
    if (this.weekSelectionInvalid()) {
      this.selectWeeksController().showWeekError();
      valid = false;
    }
    if (!this.validateFields()) {
      valid = false;
    }
    if (!this.validateHours()) {
      valid = false;
    }
    if (this.gradeCollegeTarget.checked && this.isTroisiemeForbidden()) {
      valid = false;
    }

    if (!valid) return;

    if (this.isDoubleGradeOffer()) {
      this.maxCandidatesDisplayTarget.textContent = ` (${this.maxCandidatesSourceTarget.value})`;
      openDsfrModal(this.dialogContainerTarget);
    } else {
      this.onConfirm();
    }
  }

  connect() {
    if (!this.hasGradeCollegeTarget || !this.hasGrade2eTarget) return;

    this.initialGradesValue.split(',').forEach((grade) => {
      if (grade === 'troisieme' || grade === 'quatrieme') {
        this.gradeCollegeTarget.checked = true;
      }
      if (grade === 'seconde') {
        this.grade2eTarget.checked = true;
      }
    });

    this.onClick();
  }
}
