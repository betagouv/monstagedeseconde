import $ from "jquery";
import { add, Controller } from "stimulus";
import { fetch } from "whatwg-fetch";
import { showElement, hideElement, toggleContainer } from "../utils/dom";
import {
  attach,
  detach,
  weeksCountChanged,
  broadcast,
  EVENT_LIST,
} from "../utils/events";
import { endpoints } from "../utils/api";

// @schools [School, School, School]
// return {weekId: [school, ...]}
const mapNumberOfSchoolHavingWeek = (schools) => {
  const weeksSchoolsHash = {};

  $(schools).each((ischool, school) => {
    $(school.weeks).each((iweek, week) => {
      weeksSchoolsHash[week.id] = (weeksSchoolsHash[week.id] || []).concat([
        school,
      ]);
    });
  });
  return weeksSchoolsHash;
};

export default class extends Controller {
  static targets = [
    "checkboxesContainer",
    "weekCheckboxes",
    "hint",
    "inputWeekLegend",
    "legendContainer",
    "submitButton",
    "monthScore",
    "grade2e",
    "gradeCollege",
    "period",
    "allYearLong",
  ];
  static values = {
    skipValidation: Boolean,
    longitude: Number,
    latitude: Number,
  };

  scores = {
    Janvier: 0,
    Février: 0,
    Mars: 0,
    Avril: 0,
    Mai: 0,
    Juin: 0,
    Juillet: 0,
    Août: 0,
    Septembre: 0,
    Octobre: 0,
    Novembre: 0,
    Décembre: 0,
  };

  score = 0;

  weekCheckboxesTargetConnected() {
    this.weekCheckboxesTargets.forEach((el) => {
      el.addEventListener("change", this.handleCheckboxesChanges.bind(this));
    });
    this.handleCheckboxesChanges();
  }

  disconnect() {
    this.detachEventListeners();
  }

  fetchSchoolsNearby() {
    // fetch(endpoints.apiSchoolsNearby(event.detail), { method: "POST" })
    const body = {
      longitude: this.longitudeValue,
      latitude: this.latitudeValue,
    };
    // fetch(endpoints.apiSchoolsNearby(body), { method: "POST" })
    //   .then((response) => response.json())
    //   .then(this.showSchoolDensityPerWeek);
  }

  showSchoolDensityPerWeek(schools) {
    const weeksSchoolsHash = mapNumberOfSchoolHavingWeek(schools);

    // this.inputWeekLegendTargets.each(( el) => {
    //   const weekId = parseInt(el.getAttribute("data-week-id"), 10);
    //   const schoolCountOnWeek = (weeksSchoolsHash[weekId] || []).length;

    //   el.innerText = `${schoolCountOnWeek.toString()} etablissement`;
    //   el.classList.add(
    //     (function (threshold) {
    //       switch (threshold) {
    //         case 0:
    //           return "bg-dark-70";
    //         case 1:
    //           return "bg-success-20";
    //         case 2:
    //           return "bg-success-30";
    //         case 4:
    //           return "bg-success-40";
    //         default:
    //           return "bg-success";
    //       }
    //     })(schoolCountOnWeek)
    //   );
    //   el.classList.remove("d-none");
    // });
  }

  // toggle all weeks options
  showAllYearLong(event) {
    this.unSelectThemAll();
    $(".custom-control-checkbox-list").addClass("d-none");
    toggleContainer(this.checkboxesContainerTarget, false);
    this.repaintScores();
  }

  showSpecificWeeks(event) {
    this.unChekThemAll();
    $(".custom-control-checkbox-list").removeClass("d-none");
    toggleContainer(this.checkboxesContainerTarget, true);
    this.repaintScores();
  }

  handleSubmit(event) {
    if (this.skipValidationValue) {
      return event;
    }
    if (!this.hasAtLeastOneCheckbox()) {
      this.onAtLeastOneWeekSelected();
    } else {
      this.onNoWeekSelected();
      event.preventDefault();
      return false;
    }
    return event;
  }

  // getters
  getFirstInput() {
    const inputs = this.weekCheckboxesTargets;
    return inputs[0];
  }

  getForm() {
    if (!this.getFirstInput() || !this.getFirstInput().form) return null;

    return this.getFirstInput().form;
  }

  hasAtLeastOneCheckbox() {
    const selectedCheckbox = $(this.weekCheckboxesTargets).filter(":checked");
    return selectedCheckbox.length === 0;
  }

  // ui helpers
  onNoWeekSelected() {
    const $hint = $(this.hintTarget);
    const $checkboxesContainer = $(this.checkboxesContainerTarget);
    this.submitButtonTarget.disabled = true;

    showElement($hint);
    $checkboxesContainer.addClass("is-invalid");
    try {
      $checkboxesContainer.get(0).scrollIntoView();
    } catch (e) {
      // not supported
    }
  }

  onAtLeastOneWeekSelected() {
    const $hint = $(this.hintTarget);
    const $checkboxesContainer = $(this.checkboxesContainerTarget);
    this.submitButtonTarget.disabled = false;

    hideElement($hint);
    $checkboxesContainer.removeClass("is-invalid");
  }

  unSelectThemAll() {
    this.unChekThemAll();
    this.resetScores();
    this.repaintScores();
  }

  // on week checked
  handleCheckboxesChanges(event) {
    this.hasAtLeastOneCheckbox()
      ? this.onNoWeekSelected()
      : this.onAtLeastOneWeekSelected();
  }

  handleOneCheckboxChange(event) {
    this.handleCheckboxesChanges(event);
    this.setMonthScore(event);
    this.repaintScores();
  }

  setMonthScore(event) {
    if (event == undefined) return;

    const htmlBox = event.target;
    const classList = htmlBox.parentNode.classList;
    this.monthList().forEach((monthName) => {
      if (classList.contains(monthName)) {
        this.scores[monthName] += htmlBox.checked ? 1 : -1; // action is check or uncheck;
      }
    });
  }

  repaintScores() {
    this.computeMonthScore();
    this.broadcastWeeksCount(this.totalScore());
  }

  computeMonthScore() {
    this.monthList().forEach((monthName) => {
      this.monthScoreTargets.forEach((sideElement) => {
        if (sideElement.classList.contains(monthName)) {
          const score = this.scores[monthName];
          this.switchHtmlClasses(sideElement, score);
          this.switchText(sideElement, score, monthName);
        }
      });
    });
  }

  // summary_card is a subscriptor of this event
  broadcastWeeksCount(totalScore) {
    const weeksCount = this.setWeeksMesssage(this.totalScore());
    broadcast(weeksCountChanged({ weeksCount }));
  }

  totalScore() {
    return this.computeTroisiemeScore() + this.computeSecondeScore();
  }

  computeTroisiemeScore() {
    if (!this.gradeCollegeTarget.checked) return 0;

    let troisiemeScore = 0;
    if (this.allYearLongTarget.checked) {
      troisiemeScore = document.querySelectorAll(".custom-control-checkbox-list input").length;
    } else {
      troisiemeScore = Object.values(this.scores).reduce((a, b) => a + b);
    }
    return troisiemeScore;
  }

  computeSecondeScore() {
    if (!this.grade2eTarget.checked)  return 0;

    const checkedPeriodElement = this.periodTargets.find((el) => el.checked);
    const checkedPeriod = (checkedPeriodElement) ? parseInt(checkedPeriodElement.value, 10) : 0;
    return (checkedPeriod == 2) ? 2 : 1;
  }

  onPeriodClick(_e) { this.repaintScores(); }
  onGrade2ndeClick(_e) { this.repaintScores(); }
  onGradeTroisiemeClick(_e) { this.repaintScores(); }
  monthList() { return Object.keys(this.scores); }

  switchHtmlClasses(element, score) {
    const classList = element.classList;
    if (score == 0) {
      classList.add("fr-hint-text");
      classList.remove("strong", "bold", "blue-france");
    } else {
      classList.remove("fr-hint-text");
      classList.add("strong", "bold", "blue-france");
    }
  }

  switchText(element, score, monthName) {
    const text = score == 0 ? monthName : monthName + " (" + score + ")";
    element.innerText = text;
  }

  unChekThemAll() {
    $(this.weekCheckboxesTargets).each((i, el) => {
      $(el).prop("checked", false);
    });
  }

  resetScores() {
    this.monthList().forEach((key) => {
      this.scores[key] = 0;
    });
  }

  setWeeksMesssage(totalScore) {
    const semaines = this.totalScore();
    let weeksCount = (semaines > 1) ? totalScore + " semaines proposées" : totalScore + " semaine proposée";
    return weeksCount;
  }
}
