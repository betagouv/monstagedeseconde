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
    this.element.closest('form').submit();
  }

  onValidate(event) {
    if (this.noGradeOffer()) {
      // Prevent submission if no grade is selected, SNO
      event.preventDefault();
      event.stopPropagation();
      toggleContainer(this.alertContainerTarget, true);
    } else if (this.isDoubleGradeOffer()) {
      this.maxCandidatesDisplayTarget.textContent = ` (${this.maxCandidatesSourceTarget.value})`;
      event.preventDefault();
      event.stopPropagation();
      openDsfrModal(this.dialogContainerTarget);
    } else {
      this.onConfirm();
    }
  }

  connect() {
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
