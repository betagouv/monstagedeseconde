import React, { useEffect, useState } from 'react';
// import { useDebounce } from 'use-debounce';
// import Downshift from 'downshift';
// import RadiusInput from './RadiusInput';
// import { fetch } from 'whatwg-fetch';
import { searchParamsFromHash, getParamValueFromUrl, fetchSearchParamsFromUrl, addParamToSearchParams } from '../../utils/urls';
import { on } from 'hammerjs';


// see: https://geo.api.gouv.fr/decoupage-administratif/communes
// and
// 'https://geo.api.gouv.fr/communes?codePostal=78000' --> code curl
// 'https://geo.api.gouv.fr/communes?code=78646&fields=code,nom,codesPostaux,code

function GradeInput({
  studentGradeId: defaultStudentGradeId,
  whiteBg: defaultWhiteBg, }) {

  let searchParams = fetchSearchParamsFromUrl();
  const [studentGradeId, setStudentGradeId] = useState(searchParams.get('studentGradeId') || defaultStudentGradeId || "");
  const [whiteBg, setWhiteBg] = useState(searchParams.get('whiteBg') || defaultWhiteBg || true);

  const onSelectChange = (event) => {
    const selectedOption = event.target.options[event.target.selectedIndex];
    setStudentGradeId(selectedOption.value);
    // setWhiteBg(selectedOption.value === "1" ? true : false);
    // setStudentGrade(e.target.options[e.target.selectedIndex].text);
    // searchParams = addParamToSearchParams('studentGradeId', studentGradeId);
  }

  return (
    <div className={`form-group mb-md-0 col-12 col-md ${whiteBg ? 'bg-white' : ''}`}>
      <label htmlFor="grade_id">Filière</label>
      <select 
        class="fr-select almost-fitting"
        title="Recherche par filière"
        aria-label="Recherche par filière"
        name="grade_id"
        id="grade_id"
        value={studentGradeId}
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