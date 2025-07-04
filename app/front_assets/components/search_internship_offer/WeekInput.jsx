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
  weekPlaceholder
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
      className={`form-group mb-md-0 col-12 col-md ${
        whiteBg ? "bg-white" : ""
      }`}
    >
      <label className="form-label" htmlFor="weeks-search-panel">
        <span className="d-none d-md-inline">Semaines</span>
      </label>
      <input
        className="select-like almost-fitting fr-btn fr-icon-arrow-down-s-line fr-btn--icon-right fr-select"
        title="Recherche par semaine"
        aria-label="Recherche par semaine"
        placeholder={weekPlaceholder}
        maxLength="0"
        readOnly
        onClick={toggleSearchPanel}
      />

      <div className="weeks-search-panel fr-hidden" id="weeks-search-panel">
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
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default WeekInput;
