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
    <div className="d-flex">
      <div className="fr-px-2w flex-fill align-self-end ">
        <CityInput
          city={searchParams.city}
          latitude={searchParams.latitude}
          longitude={searchParams.longitude}
          radius={searchParams.radius}
          whiteBg="false"
        />
      </div>
      <div className="fr-px-2w flex-fill align-self-end">
        <GradeInput
          gradeId={gradeId}
          whiteBackground="true"
          studentGradeId={studentGradeId}
          onGradeIdChange={onGradeIdChange}
        />
      </div>
      <div className="fr-px-2w flex-fill align-self-end">
        <WeekInput
          preselectedWeeksList={preselectedWeeksList}
          schoolWeeksList={schoolWeeksList}
          gradeId={gradeId}
          whiteBg="false"
          secondeWeekIds={secondeWeekIds}
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
