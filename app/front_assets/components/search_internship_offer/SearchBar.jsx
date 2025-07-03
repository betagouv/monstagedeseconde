import React, { useEffect, useState } from "react";
import CityInput from "./CityInput";
import GradeInput from "./GradeInput";
import WeekInput from "./WeekInput";
import {
  fetchSearchParamsFromUrl,
  getParamValueFromUrl,
  turboVisitsWithSearchParams,
  addParamToSearchParams,
  updateURLWithParam,
  parseArrayValueFromUrl,
  removeParam,
} from "../../utils/urls";

const SearchBar = ({
  searchParams,
  preselectedWeeksList,
  schoolWeeksList,
  secondeWeekIds,
  troisiemeWeekIds,
}) => {
  const gradeIdSeconde = "1";
  const gradeIdTroisieme = "2";
  const gradeIdQuatrieme = "3";
  // state variables
  const [monthScore, setMonthScore] = useState({});
  const [weekIds, setWeekIds] = useState([]);
  const [gradeId, setGradeId] = useState(searchParams.grade_id);
  const [weekPlaceholder, setWeekPlaceholder] = useState(
    "Choisissez une option"
  );
  const [weeksToParse, setWeeksToParse] = useState(schoolWeeksList);

  // helpers

  const updateGradeIdInUrl = (value) => {
    const searchParams = addParamToSearchParams("grade_id", value);
    updateURLWithParam(searchParams);
  };

  const weekIdsFromUrl = () => {
    return sanitizeWeekIds(parseArrayValueFromUrl("week_ids[]"));
  };

  const updateWeekIdsFromUrl = (gradeId) => {
    // filteredWeekIds is the intersection between weekIdsFromUrl() and troisiemeWeekIds or SecondeWeeksIds according to gradeId's value
    const WeekIdsGrandContainer = gradeId === gradeIdSeconde ? secondeWeekIds : troisiemeWeekIds;
    const filteredWeekIds = WeekIdsGrandContainer.filter((id) =>
      weekIdsFromUrl().includes(id)
    );
    // setWeekIds to the filteredWeekIds
    setWeekIds(filteredWeekIds);
  };

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
    switch (gradeId) {
      case gradeIdSeconde:
        // filter schoolWeeksList with secondeWeekIds
        setWeeksToParse(
          schoolWeeksList.filter((week) => secondeWeekIds.includes(week.id))
        );
        break;
      case gradeIdTroisieme:
        // filter schoolWeeksList with troisiemeWeekIds
        setWeeksToParse(
          schoolWeeksList.filter((week) => troisiemeWeekIds.includes(week.id))
        );
        break;
      case gradeIdQuatrieme:
        // filter schoolWeeksList with troisiemeWeekIds
        setWeeksToParse(
          schoolWeeksList.filter((week) => troisiemeWeekIds.includes(week.id))
        );
        break;
      default:
        setWeeksToParse(schoolWeeksList);
        break;
    }
  };

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
    let text = "-";
    const weeksCount = weekIdsFromUrl().length;

    if (weeksCount === 0 || weeksCount == undefined) {
      text = "Choisir une option";
    } else if (weeksCount === 1) {
      text = "1 semaine";
    } else if (weeksCount > 1) {
      text = `${weeksCount} semaines`;
    } else {
      text = "? semaines";
    }
    setWeekPlaceholder(text);
  };

  const monthDetailedList = () => {
    let monthList = [];
    const seenMonths = new Set();
    weeksToParse.forEach((week) => {
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
    return monthList;
  };

  // ------- action handlers
  const handleWeekCheck = (week) => {
    if (!week || !week.id) {
      console.warn("Week id is not defined");
      return;
    }
    // update weekIds and monthScore based on the week being in the former list of weekIds or not
    const newWeekIds = weekIds.includes(week.id)
      ? weekIds.filter((id) => id !== week.id)
      : [...weekIds, week.id];
    setWeekIds(newWeekIds);
    const searchParams = addParamToSearchParams("week_ids[]", newWeekIds);
    updateURLWithParam(searchParams);
    setMonthScoreFromUrl();
  };

  const handleSubmit = () => {
    turboVisitsWithSearchParams(fetchSearchParamsFromUrl());
  };

  const onGradeIdChange = (event) => {
    const formerGradeId = gradeId;
    const selectedOption = event.target.options[event.target.selectedIndex];
    const selectedOptionValue = selectedOption.value;
    setGradeId(selectedOptionValue);
    updateGradeIdInUrl(selectedOptionValue);

    updateURLWithParam(removeParam("week_ids[]"));
    onGradeChangeAndInitialization(selectedOptionValue);
  };

  // initialization
  useEffect(() => {
    const urlGradeId = getParamValueFromUrl("grade_id");
    setGradeId(urlGradeId);
    onGradeChangeAndInitialization(urlGradeId);
  }, []);

  // common part
  const onGradeChangeAndInitialization = (gradeId) => {
    updateWeekIdsFromUrl(gradeId);
    limitWeeksToParse(gradeId);
    setMonthScoreFromUrl();
  }

  // HTML
  return (
    <div className="d-flex">
      <div className="align-self-end" style={{ flex: 3 }}>
        <CityInput
          city={searchParams.city}
          latitude={searchParams.latitude}
          longitude={searchParams.longitude}
          radius={searchParams.radius}
          whiteBg="false"
        />
      </div>
      <div className="align-self-end" style={{ flex: 3 }}>
        <GradeInput
          gradeId={gradeId}
          whiteBackground="true"
          onGradeIdChange={onGradeIdChange}
        />
      </div>
      <div className="align-self-end" style={{ flex: 2 }}>
        <WeekInput
          monthDetailedList={monthDetailedList}
          monthScore={monthScore}
          schoolWeeksList={schoolWeeksList}
          handleWeekCheck={handleWeekCheck}
          weekIds={weekIds}
          gradeId={gradeId}
          whiteBg="false"
          weekPlaceholder={weekPlaceholder}
          />
      </div>
      <div className="flex-shrink-1 align-self-end">
        <button
          onClick={handleSubmit}
          className="fr-btn fr-btn--icon-left fr-icon-search-line"
        >
          Rechercher
        </button>
      </div>
    </div>
  );
};
export default SearchBar;
