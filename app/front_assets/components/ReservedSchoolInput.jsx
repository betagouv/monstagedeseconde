import React, { useEffect, useState } from "react";
import SearchSchool from "./SearchSchool";
import SchoolList from "./SchoolList";
import {
  updateURLWithParam,
  addParamToSearchParams,
} from "../utils/urls"; // Assuming this is the correct import path
// import { updateURLWithParam } from "../utils/url"; // Assuming this is for translations, but not used in the current code

export default function ReservedSchoolInput({
  classes,
  label,
  required,
  resourceName,
  selectClassRoom,
  existingSchools,
  existingClassRoom,
}) {
  const [checked, setChecked] = useState(existingSchools.length > 0);
  const [schoolList, setSchoolList] = useState(existingSchools || []);
  const [showSchoolAddingHint, setShowSchoolAddingHint] = useState(false);

  useEffect(() => {
    if (schoolList.length > 0) {
      setShowSchoolAddingHint(true);
    }

  }, [schoolList]);

  const toggleChange = () => {
    setChecked((prevChecked) => !prevChecked);
  };

  const addSchoolToSchoolList = ({ schoolId, schoolName, schoolQpv=false, schoolRepKind=''}) => {
    // check for nulls or undefined values
    if (!schoolId || !schoolName) {
      console.error("addSchoolToSchoolList called with invalid parameters", { schoolId, schoolName, schoolQpv, schoolRepKind});
      return;
    }
    // check for duplicates
    if (schoolList.some((school) => school.id === schoolId)) {
      console.warn(`School with id ${schoolId} is already in the list.`);
      return;
    }
    setSchoolList((prevList) => [
      ...prevList,
      { name: schoolName, id: schoolId, qpv: schoolQpv, rep_kind: schoolRepKind },
    ]);
  };

  const removeSchoolFromList = (schoolId) => {
    const lesserSchoolIdsList = schoolList.filter(
      (school) => school.id !== schoolId
    );

    setSchoolList(lesserSchoolIdsList);
    addParamToSearchParams("school_ids[]", lesserSchoolIdsList.map((school) => school.id));
    updateURLWithParam(
      addParamToSearchParams("school_ids[]", lesserSchoolIdsList.map((school) => school.id))
    );
  };


  return (
    <>
      {schoolList.map(school => (
        <input
          type='hidden'
          name={`${resourceName}[school_ids][]`}
          key={`school-id-${school.id}`}
          value={school.id}
        />
      ))}
      <br/>
      <div className="fr-checkbox-group test-school-reserved">
        <input
          type="checkbox"
          id={`${resourceName}_is_reserved`}
          name="is_reserved"
          value="true"
          aria-labelledby={`${resourceName}_is_reserved_label`}
          checked={checked}
          onChange={toggleChange}
        />
        <label
          htmlFor={`${resourceName}_is_reserved`}
          id={`${resourceName}_is_reserved_label`}
        >
          <span className="ml-1 font-weight-normal">
            Ce stage est réservé à un ou plusieurs établissements ?
          </span>
          <small className="form-text text-muted">
            Les stages réservés ne seront proposés qu'aux élèves des établissements sélectionnés.
          </small>
        </label>
      </div>
      {checked ? (
        <div>
          <SchoolList
            schools={schoolList}
            removeSchoolFromList={removeSchoolFromList}
          />
          <SearchSchool
            classes={classes}
            label={label}
            required={required}
            resourceName={resourceName}
            selectClassRoom={selectClassRoom}
            existingSchools={existingSchools}
            existingClassRoom={existingClassRoom}
            addSchoolToSchoolList={addSchoolToSchoolList}
            showSchoolAddingHint={showSchoolAddingHint}
          />
        </div>
      ) : (
        <input type="hidden" value="" name={`${resourceName}[school_ids]`} />
      )}
    </>
  );
}
