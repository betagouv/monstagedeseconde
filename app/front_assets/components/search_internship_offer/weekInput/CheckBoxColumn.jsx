import React, { useEffect, useState } from 'react';
import { getMonthName }  from '../../../utils/months';

function CheckBoxColumn({
  monthScore,
  schoolWeeksList,
  monthDetailedList,
  handleWeekCheck,
  weekIds,
  studentGradeId = null
}) {
  useEffect(() => { }, [weekIds])
  return (
    <>
      {monthDetailedList().map((month, index) => (
        <div className={`flex flex-column month-name ${month.monthName}`} key={index}>
          <div className='fr-mb-2w'>
            {/* month and year */}
            <strong>
              {getMonthName(month.month - 1)} {month.year}
            </strong>
          </div>
          {/* checkboxes and labels */}
          <div className='week-checkboxes'>
            {schoolWeeksList.filter(week => week.monthName === month.monthName).map((week, weekIndex) => {
              const weekScore = monthScore[week.monthName];
              const isChecked = weekIds.includes(week.id);
              const withBoldPresentation = weekScore > 0 && isChecked ? 'strong blue-france' : 'silenced';
              return (
                <div key={weekIndex} className="custom-control custom-checkbox">
                  <input
                    key={week.id}
                    type="checkbox"
                    className="custom-control-input"
                    id={`week-${week.id}`}
                    name={`week_ids`}
                    checked={isChecked}
                    value={week.id}
                    onChange={handleWeekCheck.bind(this, week)}
                    aria-label={`Semaine ${week.label} de ${getMonthName(week.month - 1)} ${week.year}`}
                    title={`Semaine ${week.label} de ${getMonthName(week.month - 1)} ${week.year}`}
                    data-week-id={week.id}
                  />
                  <label className={`custom-control-label ${withBoldPresentation}`} htmlFor={`week-${week.id}`}>
                    {week.label}
                  </label>
                </div>
              );
            })}
          </div>
          <div>
            <hr className='fr-mb-0' />
          </div>
        </div>
      ))}
    </>
  )
}
export default CheckBoxColumn;