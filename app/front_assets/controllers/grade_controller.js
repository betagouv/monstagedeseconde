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

  onValidate(event) {
    event.preventDefault();
    event.stopPropagation();

    if (this.submitting) return;

    if (this.noGradeOffer()) {
      toggleContainer(this.alertContainerTarget, true);
    } else if (this.gradeCollegeTarget.checked && this.isTroisiemeForbidden()) {
      event.preventDefault();
      event.stopPropagation();
    } else if (this.isDoubleGradeOffer()) {
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
