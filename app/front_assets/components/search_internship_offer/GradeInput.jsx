import React, {  useState } from 'react';
import { addParamToSearchParams, updateURLWithParam } from '../../utils/urls';

function GradeInput({
  gradeId,
  whiteBackground = true,
  onGradeIdChange
}) {

  // let searchParams = fetchSearchParamsFromUrl();
  const [whiteBg, setWhiteBg] = useState(whiteBackground);



  return (
    // <div className={`form-group mb-md-0 col-12 col-md ${whiteBg ? 'bg-white' : ''}`}>
    <div className={`form-group mb-md-0 col-12 col-md `}>
      <label htmlFor="grade_id">Filière</label>
      <select 
        className="fr-select almost-fitting"
        title="Recherche par filière"
        aria-label="Recherche par filière"
        name="grade_id"
        id="grade_id"
        value={gradeId}
        onChange={onGradeIdChange}>
        <option value="">Toutes les filières</option>
        <option value="1">seconde générale et technologique</option>
        <option value="2">troisieme générale</option>
        <option value="3">quatrieme générale</option>
      </select>
    </div>
  );
}

export default GradeInput;