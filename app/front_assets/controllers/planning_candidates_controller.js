import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = [
    'type',
    'maxCandidatesInput',
    'studentsMaxCandidatesGroup',
    'studentsMaxGroupInput',
    'collectiveButton',
    'individualButton'
  ];
  static values = {
    baseType: String
  }

  connect() { }

  disconnect() {}

  onChooseType(event) {
    this.chooseType(event.target.value)
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

    this.studentsMaxGroupInputTarget.setAttribute('max', maxCandidates);
    if (this.studentsMaxGroupInputTarget.value > maxCandidates) {
      this.studentsMaxGroupInputTarget.value = maxCandidates;
    }
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

  // private

  chooseType(value) {
    this.weeksContainerTarget.classList.remove('d-none');
    $(this.weeksContainerTarget).attr('data-select-weeks-skip-validation-value', false)
  }

  checkOnCandidateCount() {
    const maxCandidates = parseInt(this.maxCandidatesInputTarget.value, 10);
    this.studentsMaxGroupInputTarget.setAttribute('max', maxCandidates);
  }

  updateMaxCandidateCount() {
    if (this.individualButtonTarget.checked) {
      this.maxCandidatesInputTarget.setAttribute('min', 1);
      this.maxCandidatesInputTarget.setAttribute('max', 100);
      this.maxCandidatesInputTarget.setAttribute('value', 1);
      this.studentsMaxGroupInputTarget.setAttribute('min', 1);
      this.studentsMaxGroupInputTarget.setAttribute('max', 100);
      this.studentsMaxGroupInputTarget.setAttribute('value', 1);

    } else {
      this.maxCandidatesInputTarget.setAttribute('min', 2);
      this.maxCandidatesInputTarget.setAttribute('max', 100);
      this.maxCandidatesInputTarget.setAttribute('value', 2);
      this.studentsMaxGroupInputTarget.setAttribute('min', 2);
      this.studentsMaxGroupInputTarget.setAttribute('value', maxValue);
    }
  }

  withIndividualToggling() {
    this.individualButtonTarget.checked = true;
    this.studentsMaxCandidatesGroupTarget.classList.add('d-none');
    this.updateMaxCandidateCount();
  }

  withCollectiveToggling() {
    this.collectiveButtonTarget.checked = true;
    this.studentsMaxCandidatesGroupTarget.classList.remove('d-none');
    this.updateMaxCandidateCount();
  }
}
