import React, {  useState } from 'react';
import { addParamToSearchParams, updateURLWithParam } from '../../utils/urls';

function GradeInput({
  gradeId,
  setGradeId,
  whiteBackground = true,
}) {

  // let searchParams = fetchSearchParamsFromUrl();
  const [whiteBg, setWhiteBg] = useState(whiteBackground);

  const onSelectChange = (event) => {
    const selectedOption = event.target.options[event.target.selectedIndex];
    setGradeId(selectedOption.value);
    const searchParams = addParamToSearchParams('grade_id', selectedOption.value);
    updateURLWithParam(searchParams);
  }

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
        onChange={onSelectChange}>
        <option value="">Toutes les filières</option>
        <option value="1">seconde générale et technologique</option>
        <option value="2">troisieme générale</option>
        <option value="3">quatrieme générale</option>
      </select>
    </div>
  );
}

export default GradeInput;