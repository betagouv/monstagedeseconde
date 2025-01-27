import { Controller } from "stimulus";
import { toggleContainer } from "../utils/dom";
import { max } from "d3";

export default class extends Controller {
  static targets = [
    "type",
    "maxCandidatesInput",
    "studentsMaxCandidatesGroup",
    "studentsMaxGroupInput",
    "collectiveButton",
    "individualButton",
  ];

  connect = () => {
    const isCollective = this.studentsMaxGroupInputValue !== 1;
    toggleContainer(this.studentsMaxCandidatesGroupTarget, isCollective);
    
    const maxStudentsPerGroup = parseInt(this.studentsMaxGroupInputTarget.value, 10);
    if (maxStudentsPerGroup ==  1){
      toggleContainer(this.studentsMaxCandidatesGroupTarget, false);
    }
  };

  disconnect() {}

  onChooseType(event) {
    this.chooseType(event.target.value);
  }

  collectiveOptionInhibit(doInhibit) {
    if (doInhibit) {
      this.individualButtonTarget.checked = true;
      this.individualButtonTarget.focus();
    } else {
      this.collectiveButtonTarget.checked = true;
      this.withCollectiveToggling();
    }
  }

  handleMaxCandidatesChanges() {
    const maxCandidates = parseInt(this.maxCandidatesInputTarget.value, 10);

    this.studentsMaxGroupInputTarget.setAttribute("max", maxCandidates);
    if (this.studentsMaxGroupInputTarget.value > maxCandidates) {
      this.studentsMaxGroupInputTarget.value = maxCandidates;
    }
    if (maxCandidates === 1) {
      this.individualButtonTarget.checked = true;
    } else {
      this.collectiveButtonTarget.checked = true;
    }
  }

  handleMaxCandidatesPerGroupChanges() {
    this.checkOnCandidateCount();
    const maxCandidates = parseInt(this.maxCandidatesInputTarget.value, 10);
    if (maxCandidates === 1) {
      this.withIndividualToggling();
    }
  }

  toggleInternshipmaxCandidates(event) {
    const toggleValue = event.target.value;
    toggleValue === "true"
      ? this.withIndividualToggling()
      : this.withCollectiveToggling();
  }

  // private

  chooseType(value) {
    toggleContainer(true, this.weeksContainerTarget);
    // this.weeksContainerTarget.classList.remove('d-none');
    $(this.weeksContainerTarget).attr(
      "data-select-weeks-skip-validation-value",
      false
    );
  }
  // it maximizes the number of students per group with maxCandidates
  checkOnCandidateCount() {
    const maxCandidates = parseInt(this.maxCandidatesInputTarget.value, 10);
    this.studentsMaxGroupInputTarget.setAttribute("max", maxCandidates);
  }

  updateMaxCandidateCount() {
    if (this.individualButtonTarget.checked) {
      this.maxCandidatesInputTarget.setAttribute("min", 1);
      this.maxCandidatesInputTarget.setAttribute("max", 200);
      this.studentsMaxGroupInputTarget.setAttribute("min", 1);
      this.studentsMaxGroupInputTarget.setAttribute("max", 200);
      this.studentsMaxGroupInputTarget.setAttribute("value", 1);
    } else {
      this.maxCandidatesInputTarget.setAttribute("min", 2);
      this.maxCandidatesInputTarget.setAttribute("max", 200);
      this.studentsMaxGroupInputTarget.setAttribute("min", 2);
    }
  }

  withIndividualToggling() {
    this.individualButtonTarget.checked = true;
    toggleContainer(this.studentsMaxCandidatesGroupTarget, false);
    this.updateMaxCandidateCount();
  }

  withCollectiveToggling() {
    this.collectiveButtonTarget.checked = true;
    toggleContainer(this.studentsMaxCandidatesGroupTarget, true);
    this.studentsMaxCandidatesGroupTarget.setAttribute("min", 2);
    this.studentsMaxCandidatesGroupTarget.value = ("min", 2);
    this.studentsMaxGroupInputTarget.setAttribute("value", 2);
    this.updateMaxCandidateCount();
  }
}
