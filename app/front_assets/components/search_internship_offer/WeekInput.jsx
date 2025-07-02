//

import React, { useEffect, useState } from "react";
import {
  addParamToSearchParams,
  updateURLWithParam,
  parseArrayValueFromUrl,
  removeParam
} from "../../utils/urls";
import MonthColumn from "./weekInput/MonthColumn";
import CheckBoxColumn from "./weekInput/CheckBoxColumn";

function WeekInput({
  whiteBg,
  preselectedWeeksList,
  schoolWeeksList,
  gradeId,
  secondeWeekIds,
  troisiemeWeekIds,
  studentGradeId,
  params,
  setParams,
}) {
  const gradeIdSeconde = "1";
  const gradeIdTroisieme = "2";
  // state variables
  const [monthScore, setMonthScore] = useState({});
  const [weekIds, setWeekIds] = useState([]);
  const [weekPlaceholder, setWeekPlaceholder] = useState( "Choisissez une option" );
  const [weeksToParse, setWeeksToParse] = useState(schoolWeeksList);
  console.log('schoolWeeksList', schoolWeeksList);

  // initialization and triggers at each render
  useEffect(() => {
    updateWeekIdsFromUrl();
  }, []);

  // only at gradeId change and on initial render
  useEffect(() => {
    // updateURLWithParam(removeParam("week_ids[]"));
    // updateWeekIdsFromUrl();
    limitWeeksToParse(gradeId);
    setMonthScoreFromUrl();
    updateToggleButtonText();
  }, [gradeId]);

  // helpers
  const weekIdsFromUrl = () => { return sanitizeWeekIds(parseArrayValueFromUrl("week_ids[]")); };
  const updateWeekIdsFromUrl = () => {
        if (weekIdsFromUrl().length > 0) {
      setWeekIds([...weekIds, ...weekIdsFromUrl()]);
    }
  }
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
  const uniq = (value, index, array) => {
    return array.indexOf(value) === index;
  };

  const limitWeeksToParse = (gradeId) => {
    console.log('schoolWeeksList', schoolWeeksList)
    console.log('secondeWeekIds', secondeWeekIds ); // Ensure the last week has December as month
    switch (gradeId) {
      case gradeIdSeconde:
        // filter schoolWeeksList with secondeWeekIds
        setWeeksToParse(
          schoolWeeksList.filter((week) =>
            secondeWeekIds.includes(week.id)
          )
        );
        break;
      case gradeIdTroisieme:
        // filter schoolWeeksList without secondeWeekIds
        setWeeksToParse(
          schoolWeeksList.filter((week) =>
            troisiemeWeekIds.includes(week.id)
          )
        );
        break;
      default:
        setWeeksToParse(schoolWeeksList);
        break;
    }
  }

  const setMonthScoreFromUrl = () => {
    monthDetailedList().forEach((month) => {
      // Ensure each month starts with a score of at least 0
      setMonthScore((prevScore) => ({
        ...prevScore,
        [month.monthName]: 0,
      }));

      preselectedWeeksList.forEach((week) => {
        if (
          weekIdsFromUrl().length > 0 &&
          week.monthName === month.monthName &&
          weekIdsFromUrl().includes(week.id)
        ) {
          setMonthScore((prevScore) => ({
        ...prevScore,
        [week.monthName]: (prevScore[week.monthName] || 0) + 1,
          }));
        }
      });
    });
    updateToggleButtonText();
  };

  const updateToggleButtonText = () => {
    let text = '-';
    const weeksCount =weekIdsFromUrl().length;

    if(weeksCount === 0 || weeksCount == undefined) {
      text = 'Choisir une option';
    } else if(weeksCount === 1) {
      text = "1 semaine";
    } else if (weeksCount > 1) {
      text = `${weeksCount} semaines`;
    } else { text = '? semaines'; }
    setWeekPlaceholder(text);
  };

  const monthDetailedList = () => {
    let monthList = [];
    const seenMonths = new Set();
    console.log('weeksToParse', weeksToParse);
    weeksToParse.forEach((week) => {
      if ( week.month === 12) {
        console.log("week", week);
      }
      const key = `${week.monthName}-${week.year}`;
      if (!seenMonths.has(key)) {
        seenMonths.add(key);
        monthList.push({
          key: key,
          monthName: week.monthName,
          month: week.month,
          year: week.year,
        });
      }
    });
    console.log('-----------')
    console.log('monthList', monthList);
    console.log('-----------')
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

    const searchParams = addParamToSearchParams("week_ids[]", newWeekIds);
    updateURLWithParam(searchParams);

    // Update the monthScore state
    // const newScore = { ...monthScore };
    // const increment = shallBeAddedToWeekList ? 1 : -1;
    // newScore[week.monthName] = (newScore[week.monthName] || 0) + increment;
    // setMonthScore((prevScore) => ({
    //   ...prevScore,
    //   [week.monthName]: newScore[week.monthName],
    // }));
        setMonthScoreFromUrl();
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
              monthDetailedList={monthDetailedList}
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
                monthDetailedList={monthDetailedList}
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
