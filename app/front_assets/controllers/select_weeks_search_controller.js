import $ from "jquery";
import { Controller } from "stimulus";
// import { toggleContainer } from "../utils/dom";


export default class extends Controller {
  static targets = [
    "checkboxesContainer",
    "weekCheckboxes",
    "inputWeekLegend",
    "legendContainer",
    "monthScore",
    "period",
    "allYearLong",
  ];

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
    this.setInitialScores();
  }

  disconnect() {
    this.detachEventListeners();
  }

  setInitialScores() {
    this.monthList().forEach((key) => {
      const monthContentSelector = document.querySelectorAll(`.${key}`)[0];
      if (monthContentSelector) {
        this.scores[key] = parseInt(monthContentSelector.innerHTML.replace(/\D/g, ""), 10);
      }
    });
  }

  hasNoCheckboxChecked() {
    const selectedCheckbox = $(this.weekCheckboxesTargets).filter(":checked");
    return selectedCheckbox.length === 0;
  }

    // ui helpers
  onNoWeekSelected() {
    const $checkboxesContainer = $(this.checkboxesContainerTarget);
    $checkboxesContainer.addClass("is-invalid");
    try {
      $checkboxesContainer.get(0).scrollIntoView();
    } catch (e) {
      // not supported
    }
  }

  unSelectThemAll() {
    this.unChekThemAll();
    this.resetScores();
    this.repaintScores();
  }

  // on week checked
  handleCheckboxesChanges(event) {
    this.hasNoCheckboxChecked()
      ? this.onNoWeekSelected()
      : this.checkboxesContainerTarget.classList.remove("is-invalid");;
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

  // unChekThemAll() {
  //   $(this.weekCheckboxesTargets).each((i, el) => {
  //     $(el).prop("checked", false);
  //   });
  // }

  // resetScores() {
  //   this.monthList().forEach((key) => {
  //     this.scores[key] = 0;
  //   });
  // }

  // setWeeksMesssage(totalScore) {
  //   const semaines = this.totalScore();
  //   let weeksCount = (semaines > 1) ? totalScore + " semaines proposées" : totalScore + " semaine proposée";
  //   return weeksCount;
  // }
}
