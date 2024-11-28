
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

  connect() {
    // if (this.getForm() === null) {
    //   return;
    // }
    // this.onCoordinatesChangedRef = this.fetchSchoolsNearby.bind(this);
    // this.onSubmitRef = this.handleSubmit.bind(this);
    // this.onApiSchoolsNearbySuccess = this.showSchoolDensityPerWeek.bind(this);
    // this.attachEventListeners();
    this.fetchSchoolsNearby();
  }

  weekCheckboxesTargetConnected() {
    this.weekCheckboxesTargets.forEach((el) => {
      el.addEventListener("change", this.handleCheckboxesChanges.bind(this));
    });
    this.handleCheckboxesChanges();
  }

  disconnect() {
    this.detachEventListeners();
  }

  // attachEventListeners() {
  //   attach(EVENT_LIST.COORDINATES_CHANGED, this.onCoordinatesChangedRef);
  //   $(this.getForm()).on("submit", this.onSubmitRef);
  // }

  // detachEventListeners() {
  //   detach(EVENT_LIST.COORDINATES_CHANGED, this.onCoordinatesChangedRef);
  //   $(this.getForm()).off("submit", this.onSubmitRef);
  // }

  fetchSchoolsNearby() {
    // fetch(endpoints.apiSchoolsNearby(event.detail), { method: "POST" })
    const body = {longitude: this.longitudeValue, latitude: this.latitudeValue};
    fetch(endpoints.apiSchoolsNearby(body), { method: "POST" })
      .then((response) => response.json())
      .then(this.showSchoolDensityPerWeek);
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
  }

  showSpecificWeeks(event) {
    this.unChekThemAll();
    $(".custom-control-checkbox-list").removeClass("d-none");
    toggleContainer(this.checkboxesContainerTarget, true);
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
    if (!this.getFirstInput() || !this.getFirstInput().form) {
      return null;
    }
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

  unChekThemAll() {
    $(this.weekCheckboxesTargets).each((i, el) => {
      $(el).prop("checked", false);
    });
  }

  resetScores() {
    Object.keys(this.scores).forEach((key) => {
      this.scores[key] = 0;
    });
  }

  // on week checked
  handleCheckboxesChanges(event) {
    (this.hasAtLeastOneCheckbox()) ? this.onNoWeekSelected() : this.onAtLeastOneWeekSelected() ;
  }

  handleOneCheckboxChange(event) {
    this.handleCheckboxesChanges(event);
    this.setMonthScore(event);
    this.repaintScores();
  }

  repaintScores() {
    this.monthList().forEach((monthName) => {
      this.monthScoreTargets.forEach((sideElement) => {
        if (sideElement.classList.contains(monthName)) {
          const score = this.scores[monthName];
          this.switchClasses(sideElement, score);
          this.switchText(sideElement, score, monthName);
        }
      });
    });
    this.broadcastWeeksCount();
  }

  setMonthScore(event) {
    if (event == undefined) {
      return;
    }

    const htmlBox = event.target;
    const classList = htmlBox.parentNode.classList;
    this.monthList().forEach((monthName) => {
      if (classList.contains(monthName)) {
        const addedValue = htmlBox.checked ? 1 : -1;
        this.scores[monthName] += addedValue;
      }
    });
  }

  monthList() {
    return Object.keys(this.scores);
  }

  switchClasses(element, score) {
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
    const text = (score == 0) ? monthName : monthName + " (" + score + ")";
    element.innerText = text;
  }

  totalScore() {
    return Object.values(this.scores).reduce((a, b) => a + b);
  }

  // summary_card is a subscriptor of this event
  broadcastWeeksCount() {
    const semaines = this.totalScore();
    let weeksCount = semaines + " semaine";
    if (semaines > 1) { weeksCount += "s"; }
    broadcast(weeksCountChanged({ weeksCount }));
  }
}
