import { Controller } from 'stimulus';
import $ from 'jquery';
import { showElement, hideElement } from '../utils/dom';

export default class extends Controller {
  static targets = [
    'type',
    'maxCandidatesInput',
    'studentsMaxCandidatesGroup',
    'collectiveButton',
    'individualButton'
  ];
  static values = {
    baseType: String
  }

  onChooseType(event) {
    this.chooseType(event.target.value)
  }

  chooseType(value) {
    showElement($(this.weeksContainerTarget))
    $(this.weeksContainerTarget).attr('data-select-weeks-skip-validation-value', false)
  }

  checkOnCandidateCount() {
    const maxCandidates = parseInt(this.maxCandidatesInputTarget.value, 10);
    this.studentsMaxGroupInputTarget.setAttribute('max', maxCandidates);
  }

  updateMaxCandidateCount() {
    if (this.individualButtonTarget.checked) {
      $(this.maxCandidatesInputTarget).prop('min', 1);
      $(this.maxCandidatesInputTarget).prop('max', 100);
      $(this.maxCandidatesInputTarget).prop('value', 1);

    } else {
      $(this.maxCandidatesInputTarget).prop('min', 2);
      $(this.maxCandidatesInputTarget).prop('max', 100);
      $(this.maxCandidatesInputTarget).prop('value', 2);
    }
  }

  collectiveOptionInhibit(doInhibit) {
    if (doInhibit) {
      this.individualButtonTarget.checked = true;
      this.individualButtonTarget.focus()
    } else {
      this.collectiveButtonTarget.checked = true;
      this.withCollectiveToggling();
    }
  }

  handleMaxCandidatesChanges() {
    const maxCandidates = parseInt(this.maxCandidatesInputTarget.value, 10);

    $(this.studentsMaxGroupInputTarget).prop('max', maxCandidates);
    if (maxCandidates === 1) {
      this.individualButtonTarget.checked = true}
    else {
      this.collectiveButtonTarget.checked = true;
    }
  }

  handleMaxCandidatesPerGroupChanges() {
    this.checkOnCandidateCount();
    const maxCandidates = parseInt(this.maxCandidatesInputTarget.value, 10)
    if (maxCandidates === 1) { this.withIndividualToggling() }
  }

  toggleInternshipmaxCandidates(event) {
    const toggleValue = event.target.value;
    (toggleValue === 'true') ? this.withIndividualToggling() : this.withCollectiveToggling();
  }

  withIndividualToggling() {
    this.individualButtonTarget.checked = true;
    this.updateMaxCandidateCount();
  }

  withCollectiveToggling() {
    this.collectiveButtonTarget.checked = true;
    this.updateMaxCandidateCount();
  }

  connect() {
  }

  disconnect() {}
}
