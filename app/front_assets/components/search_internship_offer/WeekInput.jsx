//

import React, { useEffect, useState } from "react";
import {
  addParamToSearchParams,
  updateURLWithParam,
  parseArrayValueFromUrl,
} from "../../utils/urls";
import MonthColumn from "./weekInput/MonthColumn";
import CheckBoxColumn from "./weekInput/CheckBoxColumn";

function WeekInput({
  whiteBg,
  preselectedWeeksList,
  schoolWeeksList,
  gradeId,
  secondeWeekIds,
  studentGradeId,
  params,
  setParams,
}) {
  // state variables
  const [monthScore, setMonthScore] = useState([]);
  const [weekIds, setWeekIds] = useState([]);
  const [weekPlaceholder, setWeekPlaceholder] = useState( "Choisissez une option" );
  const [weeksToParse, setWeeksToParse] = useState([]);
  const gradeIdSeconde = "1";
  const gradeIdTroisieme = "2";

  // initialization and triggers
  useEffect(() => {
    const weekIdsFromUrl = parseArrayValueFromUrl("week_ids[]");
    setWeekIds(
      weekIdsFromUrl.length > 0 ? sanitizeWeekIds(weekIdsFromUrl) : []
    );
    monthIncludedInSchoolWeeksList(gradeId).forEach((month) => {
      preselectedWeeksList.forEach((week) => {
        if (
          weekIdsFromUrl.length > 0 &&
          week.monthName === month.monthName &&
          weekIdsFromUrl.includes(week.id)
        ) {
          setMonthScore((prevScore) => ({
            ...prevScore,
            [week.monthName]: (prevScore[week.monthName] || 0) + 1,
          }));
        }
      });
    });

    setWeekPlaceholder(semainesStr(totalWeeksCount));
  }, []);

  useEffect(() => {
    const searchParams = addParamToSearchParams("week_ids[]", weekIds);
    updateURLWithParam(searchParams);
    setWeekPlaceholder(semainesStr(totalWeeksCount));
  }, [weekIds]);

  useEffect(() => {
    console.log('----------------')
    console.log("gradeId", gradeId);
    console.log("secondeWeekIds", secondeWeekIds);
    switch (gradeId) {
      case gradeIdSeconde:
        console.log("en seconde");
        // filter schoolWeeksList with secondeWeekIds
        setWeeksToParse(
          schoolWeeksList.filter((week) =>
            secondeWeekIds.includes(week.id)
          )
        );
        break;
      case gradeIdTroisieme:
        console.log("en troisieme");
        // filter schoolWeeksList without secondeWeekIds
        setWeeksToParse(
          schoolWeeksList.filter((week) =>
            troisiemeWeekIds.includes(week.id)
          )
        );
        break;
    }
    setWeekPlaceholder(semainesStr(totalWeeksCount));
  }, [gradeId]);

  // helpers
  const sanitizeWeekIds = (ids) => {
    if (Array.isArray(ids) && ids.length === 0) {
      return [];
    } else if (Array.isArray(ids)) {
      return ids
        .filter(uniq)
        .filter((id) => id !== "")
        .sort();
    }
    let result = ids;
    if (typeof ids === "string") {
      result = ids.trim();
      if (result === "") {
        return [];
      } else if (result.includes(",")) {
        result = result
          .split(",")
          .map((id) => id.trim())
          .filter((id) => id !== "")
          .sort();
      } else {
        result = [result];
      }
      return result;
    }
    return [];
  };

  const totalWeeksCount = Object.values(monthScore).reduce(
    (acc, score) => acc + score,
    0
  );

  const uniq = (value, index, array) => {
    return array.indexOf(value) === index;
  };

  const semainesStr = (count) => {
    if (count === 0) {
      return "Choisir une option";
    } else if (count === 1) {
      return "1 semaine";
    } else if (count > 1 && count < 5) {
      return `${count} semaines`;
    } else {
      return "-";
    }
  };

  const monthIncludedInSchoolWeeksList = () => {
    let monthList = [];
    weeksToParse.forEach((week) => {
      if (!weeksToParse.some((month) => month.monthName === week.monthName)) {
        monthList.push({
          monthName: week.monthName,
          month: week.month,
          year: week.year,
        });
      }
    });
    return monthList;
  };

  // action handlers
  const handleWeekCheck = (week) => {
    if (!week || !week.id) {
      console.warn("Week id is not defined");
      return;
    }
    // update weekIds and monthScore based on the week being in the former list of weekIds or not
    const wasChecked = weekIds.includes(week.id);
    const shallBeAddedToWeekList = !wasChecked;

    // Update the weekIds state
    const newWeekIds = shallBeAddedToWeekList
      ? [...weekIds, week.id]
      : weekIds.filter((id) => id !== week.id);
    setWeekIds(newWeekIds);

    // Update the monthScore state
    const newScore = { ...monthScore };
    const increment = shallBeAddedToWeekList ? 1 : -1;
    newScore[week.monthName] = (newScore[week.monthName] || 0) + increment;
    setMonthScore((prevScore) => ({
      ...prevScore,
      [week.monthName]: newScore[week.monthName],
    }));
  };

  const toggleSearchPanel = (e) => {
    e.preventDefault();
    e.stopPropagation();
    const panel = document.getElementById("weeks-search-panel");
    if (panel.classList) {
      panel.classList.toggle("d-none");
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

      <div className="weeks-search-panel d-none" id="weeks-search-panel">
        <div className="d-flex">
          <div className=" small-interline fr-text--sm border-right month-lane">
            <MonthColumn
              monthIncludedInSchoolWeeksList={monthIncludedInSchoolWeeksList}
              monthScore={monthScore}
              secondeWeekIds={secondeWeekIds}
              gradeId={gradeId}
            />
          </div>
          <div className=" flex-fill weeks-list">
            <div className="custom-control-checkbox-list">
              <CheckBoxColumn
                monthScore={monthScore}
                schoolWeeksList={schoolWeeksList}
                monthIncludedInSchoolWeeksList={monthIncludedInSchoolWeeksList}
                handleWeekCheck={handleWeekCheck}
                weekIds={weekIds}
                secondeWeekIds={secondeWeekIds}
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
