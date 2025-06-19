//

import React, { useEffect, useState } from 'react';
import {  getParamValueFromUrl , addParamToSearchParams, updateURLWithParam} from '../../utils/urls';
import { getMonthName }  from '../../utils/months';
import MonthColumn from './weekInput/MonthColumn';
import CheckBoxColumn from './weekInput/CheckBoxColumn';

function WeekInput({
  whiteBg,
  studentGradeId,
  preselectedWeeksList,
  schoolWeeksList,
  gradeId,
  setGradeId
}) {

  const [monthScore, setMonthScore] = useState({
    Janvier: 0,
    Février: 0,
    Mars: 0,
    Avril: 0,
    Mai: 0,
    Juin: 0,
    Juillet: 0,
    Août: 0,
    Septembre: 0,
    Octobre: 0,
    Novembre: 0,
    Décembre: 0,
  });

  const [weekIds, setWeekIds] = useState(getParamValueFromUrl('week_ids') || []);

  // initialization
  useEffect(() => {
    monthIncludedInSchoolWeeksList().forEach(month => {
      preselectedWeeksList.forEach(week => {
        if ((week.monthName === month.monthName) && (weekIds.includes(week.id))) {
          setMonthScore(prevScore => ({
            ...prevScore,
            [week.monthName]: (prevScore[week.monthName] || 0) + 1
          }));
        }
      });
    });
  }, []);

  useEffect(() => {
    const searchParams = addParamToSearchParams('week_ids', weekIds);
    updateURLWithParam(searchParams);
  }, [weekIds]);

  useEffect(() => { }, [preselectedWeeksList]);

  const monthIncludedInSchoolWeeksList = () =>{
    let monthList = [];
    schoolWeeksList.forEach(week => {
      if (!monthList.some(month => month.monthName === week.monthName)) {
        monthList.push({ monthName: week.monthName, month: week.month, year: week.year });
      }
    });
    return monthList;
  }

  const toggleSearchPanel = (e) => {
    e.preventDefault();
    e.stopPropagation();
    const panel = document.getElementById('weeks-search-panel');
    if (panel.classList) {
      panel.classList.toggle('d-none');
    } else {
      console.warn('Weeks search panel not found');
    }
  };

  const handleWeekCheck = (week) => {
    const newScore = { ...monthScore };
    newScore[week.monthName] += (weekIds.includes(week.id)) ? -1 : 1;
    setMonthScore(prevScore => ({
              ...prevScore,
              [week.monthName]: newScore[week.monthName]
            }));
    setWeekIds(prevIds => (
      weekIds.includes(week.id)
        ? prevIds.filter(id => id !== week.id)
        : [...prevIds, week.id]
    ));
  };

  return (
    <div className={`form-group mb-md-0 col-12 col-md ${whiteBg ? 'bg-white' : ''}`}>
      <label className="form-label" htmlFor="weeks-search-panel">
        <span className="d-none d-md-inline">Semaines</span>
      </label>
      <input className='select-like almost-fitting fr-btn fr-icon-arrow-down-s-line fr-btn--icon-right fr-select'
            title="Recherche par semaine"
            aria-label="Recherche par semaine"
            placeholder="Choisissez une option"
            maxLength='0'
            readOnly
            onClick={toggleSearchPanel} />

      <div className="weeks-search-panel d-none" id="weeks-search-panel">
        <div className='d-flex'>
          <div className=' small-interline fr-text--sm border-right month-lane'>
             <MonthColumn
               monthIncludedInSchoolWeeksList={monthIncludedInSchoolWeeksList}
               monthScore={monthScore}
             />
          </div>
          <div className=' flex-fill weeks-list'>
            <div className='custom-control-checkbox-list'>
              <CheckBoxColumn
                monthScore={monthScore}
                schoolWeeksList={schoolWeeksList}
                monthIncludedInSchoolWeeksList={monthIncludedInSchoolWeeksList}
                handleWeekCheck={handleWeekCheck}
                weekIds={weekIds}
              />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default WeekInput;