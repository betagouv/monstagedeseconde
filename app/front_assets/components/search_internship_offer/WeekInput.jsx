//

import React from "react";

import MonthColumn from "./weekInput/MonthColumn";
import CheckBoxColumn from "./weekInput/CheckBoxColumn";

function WeekInput({
  schoolWeeksList,
  gradeId,
  whiteBg = "false",
  monthDetailedList,
  monthScore,
  handleWeekCheck,
  weekIds,
  weekPlaceholder,
  uncheckAllWeeks,
  studentGradeId = null
}) {

  const toggleSearchPanel = (e) => {
    e.preventDefault();
    e.stopPropagation();
    const panel = document.getElementById("weeks-search-panel");
    if (panel.classList) {
      panel.classList.toggle("fr-hidden");
    } else {
      console.warn("Weeks search panel not found");
    }
  };

  // HTML
  return (
    <div
      className={`fr-input-group mb-md-0 col-md ${
        whiteBg ? "bg-white" : ""
      }`}
    >
      <label className="fr-label" htmlFor="weeks-search-panel">
        <span className="">Dates de stage</span>
      </label>
      <input
        className="select-like fr-btn fr-icon-arrow-down-s-line fr-btn--icon-right fr-select"
        title="Recherche par semaine"
        aria-label="Recherche par semaine"
        placeholder={weekPlaceholder}
        maxLength="0"
        readOnly
        onClick={toggleSearchPanel}
      />

      <div className="weeks-search-panel fr-hidden" id="weeks-search-panel">

        <div className='fr-mr-1w text-right'>
          <button
            className='fr-btn fr-btn--sm fr-btn--tertiary'
            onClick={uncheckAllWeeks}>
            Tout décocher
          </button>
        </div>
        <div className="d-flex">
          <div className=" small-interline fr-text--sm border-right month-lane">
            <MonthColumn
              monthDetailedList={monthDetailedList}
              monthScore={monthScore}
            />
          </div>
          <div className=" flex-fill weeks-list">
            <div className="custom-control-checkbox-list">
              <CheckBoxColumn
                monthDetailedList={monthDetailedList}
                monthScore={monthScore}
                schoolWeeksList={schoolWeeksList}
                handleWeekCheck={handleWeekCheck}
                weekIds={weekIds}
                gradeId={gradeId}
                studentGradeId={studentGradeId}
                uncheckAllWeeks={uncheckAllWeeks}
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default WeekInput;
