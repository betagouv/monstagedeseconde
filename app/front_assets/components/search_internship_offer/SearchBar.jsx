import React from "react";
import { fetchSearchParamsFromUrl, turboVisitsWithSearchParams, addParamToSearchParams, updateURLWithParam} from "../../utils/urls";
import CityInput from "./CityInput";
import GradeInput from "./GradeInput";
import WeekInput from "./WeekInput";

const SearchBar = ({
  searchParams,
  setGradeId,
  gradeId,
  preselectedWeeksList,
  schoolWeeksList,
  secondeWeekIds,
  troisiemeWeekIds,
  studentGradeId,
  params,
  setParam
}) => {
  const handleSubmit = () => {
    turboVisitsWithSearchParams(fetchSearchParamsFromUrl());
  };

  const onGradeIdChange = (event) => {
    const selectedOption = event.target.options[event.target.selectedIndex];
    setGradeId(selectedOption.value);
    const searchParams = addParamToSearchParams('grade_id', selectedOption.value);
    updateURLWithParam(searchParams);
  }
  // HTML
  return (
    <div className="d-flex" >
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
          studentGradeId={studentGradeId}
          onGradeIdChange={onGradeIdChange}
        />
      </div>
      <div className="align-self-end" style={{ flex: 2}}>
        <WeekInput
          preselectedWeeksList={preselectedWeeksList}
          schoolWeeksList={schoolWeeksList}
          gradeId={gradeId}
          whiteBg="false"
          secondeWeekIds={secondeWeekIds}
          troisiemeWeekIds={troisiemeWeekIds}
          studentGradeId={studentGradeId}
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
