import React, {  useState } from 'react';
import { addParamToSearchParams, updateURLWithParam } from '../../utils/urls';

function GradeInput({
  gradeId,
  whiteBackground = true,
  onGradeIdChange,
  studentGradeId
}) {

  // let searchParams = fetchSearchParamsFromUrl();
  const [whiteBg, setWhiteBg] = useState(whiteBackground);

  // Define all grade options
  const gradeOptions = [
    { value: "1", label: "2de générale et technologique" },
    { value: "2", label: "3e" },
    { value: "3", label: "4e" }
  ];

  // Filter options based on studentGradeId
  const filteredOptions = studentGradeId
    ? gradeOptions.filter(option => option.value === String(studentGradeId))
    : gradeOptions;

  return (
    <div className={`fr-input-group mb-md-0 col-12 col-md `}>
      <label htmlFor="grade_id">Niveau de classe</label>
      <select 
        className="fr-select fr-mt-1v"
        title="Recherche par niveau"
        aria-label="Recherche par niveau"
        name="grade_id"
        id="grade_id"
        value={gradeId}
        onChange={onGradeIdChange}
      >
        {!studentGradeId && (
          <option value="">Choisir sa classe</option>
        )}
        {filteredOptions.map(option => (
          <option key={option.value} value={option.value}>{option.label}</option>
        ))}
      </select>
    </div>
  );
}

export default GradeInput;