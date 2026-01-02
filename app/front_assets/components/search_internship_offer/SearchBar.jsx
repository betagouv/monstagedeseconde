import React, { useEffect, useState } from 'react';
import CityInput from './CityInput';
import GradeInput from './GradeInput';
import WeekInput from './WeekInput';
import {
  path,
  fetchSearchParamsFromUrl,
  getParamValueFromUrl,
  turboVisitsWithSearchParams,
  addParamToSearchParams,
  updateURLWithParam,
  parseArrayValueFromUrl,
  removeParam,
} from '../../utils/urls';

const SearchBar = ({
  searchParams,
  preselectedWeeksList,
  schoolWeeksList,
  secondeWeekIds,
  troisiemeWeekIds,
  studentGradeId,
  origin,
}) => {
  const gradeIdSeconde = '1';
  const gradeIdTroisieme = '2';
  const gradeIdQuatrieme = '3';
  // state variables
  const [monthScore, setMonthScore] = useState({});
  const [weekIds, setWeekIds] = useState(schoolWeeksList || []);
  const [gradeId, setGradeId] = useState(studentGradeId || searchParams.grade_id || 0);
  const [weekPlaceholder, setWeekPlaceholder] = useState('Choisissez une option');
  const [weeksToParse, setWeeksToParse] = useState(schoolWeeksList);

  // helpers

  const updateGradeIdInUrl = (value) => {
    const updatedSearchParams = addParamToSearchParams('grade_id', value);
    updateURLWithParam(updatedSearchParams);
  };

  const sanitizeWeekIds = (ids) => {
    if (Array.isArray(ids) && ids.length === 0) {
      return [];
    } else if (Array.isArray(ids)) {
      return ids
        .filter(uniq)
        .filter((id) => id !== '')
        .sort();
    }

    let result = ids;
    if (typeof ids === 'string') {
      result = ids.trim();
      if (result === '') {
        return [];
      } else if (result.includes(',')) {
        result = result
          .split(',')
          .map((id) => id.trim())
          .filter((id) => id !== '')
          .sort();
      } else {
        result = [result];
      }
      return result;
    }
    return [];
  };

  const weekIdsFromUrl = () => {
    return sanitizeWeekIds(parseArrayValueFromUrl("week_ids[]"));
  };

  const updateWeekIdsFromUrl = (aGradeId) => {
    let WeekIdsGrandContainer;
    if (aGradeId === undefined) {
      WeekIdsGrandContainer = [...secondeWeekIds, ...troisiemeWeekIds];
    } else if (aGradeId === gradeIdSeconde) {
      WeekIdsGrandContainer = secondeWeekIds;
    } else {
      WeekIdsGrandContainer = troisiemeWeekIds;
    }
    // filteredWeekIds is the intersection between weekIdsFromUrl() and troisiemeWeekIds or SecondeWeeksIds according to gradeId's value
    const filteredWeekIds = WeekIdsGrandContainer.filter((id) => weekIdsFromUrl().includes(id));
    // setWeekIds to the filteredWeekIds
    setWeekIds(filteredWeekIds);
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
    let text = '-';
    const weeksCount = weekIdsFromUrl().length;

    if (weeksCount === 0 || weeksCount === undefined) {
      text = 'Choisissez une semaine';
    } else if (weeksCount === 1) {
      text = '1 semaine';
    } else if (weeksCount > 1) {
      text = `${weeksCount} semaines`;
    } else {
      text = '? semaines';
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
          key,
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
    if (origin == 'homeStudent') {
      Turbo.visit(`${ window.location.origin }${"/offres-de-stage"}?${fetchSearchParamsFromUrl()}`);
    } else if (origin === 'search') {
      turboVisitsWithSearchParams(fetchSearchParamsFromUrl());
    }
  };

  const onGradeIdChange = (event) => {
    // const formerGradeId = gradeId;
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
  };

  const uncheckAllWeeks = () => {
    setWeekIds([]);
    updateURLWithParam(removeParam("week_ids[]"));
    setMonthScoreFromUrl();
  };

  // HTML
  return (
    <>
      <div className="fr-my-2w fr-hidden-md w-100 text-center ">
        <h1 className="h4 ">Recherche de stage</h1>
      </div>
      <div className="fr-grid-row fr-sm-mt-n2w">
        <div className="fr-col-sm-12 w-100 fr-col-lg-4 fr-sm-mt-n2w fr-mt-2w">
          <CityInput
            city={searchParams.city}
            latitude={searchParams.latitude}
            longitude={searchParams.longitude}
            radius={searchParams.radius}
            whiteBg="false"
          />
        </div>
        <div className="fr-col-sm-12 w-100 fr-col-lg-3 fr-sm-mt-n2w fr-mt-2w">
          <GradeInput
            gradeId={gradeId}
            whiteBackground="true"
            onGradeIdChange={onGradeIdChange}
            studentGradeId={studentGradeId}
          />
        </div>
        <div className="fr-col-sm-12 w-100 fr-col-lg-3 fr-sm-mt-n2w fr-mt-2w">
          <WeekInput
            monthDetailedList={monthDetailedList}
            monthScore={monthScore}
            schoolWeeksList={schoolWeeksList}
            handleWeekCheck={handleWeekCheck}
            weekIds={weekIds}
            gradeId={gradeId}
            whiteBg="false"
            weekPlaceholder={weekPlaceholder}
            studentGradeId={studentGradeId}
            uncheckAllWeeks={uncheckAllWeeks}
          />
        </div>
        <div className="fr-col-sm-12 w-100 fr-col-lg-2 fr-hidden fr-unhidden-md">
          <button
            type="button"
            onClick={handleSubmit}
            className="fr-btn fr-btn--icon-left fr-icon-search-line fr-mt-6w fr-mr-1w"
          >
            Rechercher
          </button>
        </div>
      </div>
    </>
  );
};
export default SearchBar;
