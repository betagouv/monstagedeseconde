import React, { useEffect, useState } from "react";

function RenderSchoolSelectInput({
  setClassRoomsSuggestions,
  setSelectedSchool,
  selectedSchool,
  schoolsInCitySuggestions,
  existingSchools,
  resourceName,
  classes,
  addSchoolToSchoolList,
  onResetSearch,
}) {
  const isWaitingCitySelection =
    schoolsInCitySuggestions.length === 0 && !selectedSchool && !existingSchool;
  const isAlreadySelected =
    schoolsInCitySuggestions.length === 0 && existingSchool;
  const hasPendingSuggestion = schoolsInCitySuggestions.length > 0;

  const renderSchoolOption = (school) => (
    <option key={`school-${school.id}`} value={school.id}>
      {school.name}
    </option>
  );
  const existingSchool = existingSchools.length === 0 ? undefined : existingSchools.slice(-1)[0];

  const selectSchool = (school_id) => {
    if (!school_id) {
      console.error("selectSchool called without school_id");
      return;
    }
    // get school name from its id
    const school = schoolsInCitySuggestions.find(
      (school) => school.id === parseInt(school_id, 10)
    );
    // setSelectedSchool(school);
    setClassRoomsSuggestions(school.class_rooms);
    addSchoolToSchoolList({ schoolId: school_id, schoolName: school.name });
    onResetSearch();
  };


  return (
    <div className={`${isWaitingCitySelection ? "opacity-05" : ""}`}>
      {isWaitingCitySelection && (
        
        <div className="fr-mt-2w">
          <label className="fr-label" htmlFor={`${resourceName}_school_name`}>
            Établissement
          </label>
          <input
            value=""
            disabled
            placeholder="Sélectionnez une option"
            className={`fr-input ${classes || ""}`}
            type="text"
            id={`${resourceName}_school_name`}
          />
        </div>
      )}
      {isAlreadySelected && (
        <div className="">
          <label className="fr-label" htmlFor={`${resourceName}_school_name`}>
            Établissement
          </label>
          <input
            readOnly
            disabled
            className={`fr-input ${classes || ""}`}
            type="text"
            value={existingSchool.name}
            name={`${resourceName}[school_name]`}
            id={`${resourceName}_school_name`}
          />

          <input
            type="hidden"
            value={existingSchool.id}
            name={`${resourceName}[school_id]`}
          />
        </div>
      )}
      {hasPendingSuggestion && (
        <div className="">
          <div className="">
            <label
              htmlFor={`${resourceName}_school_id`}
              className="fr-label fr-mt-2w"
            >
              Établissement
            </label>
            <select
              id={`${resourceName}_school_id`}
              name={`${resourceName}[school_id]`}
              onChange={(e) => {
                selectSchool(e.target.value);
              }}
              required
              className="fr-select"
              value={selectedSchool ? selectedSchool.id : ""}
            >
              {!selectedSchool && (
                <option key="school-null" disabled value="">
                  -- Veuillez choisir un établissement --
                </option>
              )}

              {(schoolsInCitySuggestions || []).map(renderSchoolOption)}
            </select>
          </div>
        </div>
      )}
    </div>
  );
}

export default RenderSchoolSelectInput;
