import React, { useEffect, useState } from 'react';
import { getMonthName }  from '../../../utils/months';

function MonthColumn({
  monthIncludedInSchoolWeeksList,
  monthScore,
  gradeId,
}) {
  return(
    <div>
      { monthIncludedInSchoolWeeksList().map((month, index) => {
        const withBoldPresentation = monthScore[month.monthName] > 0 ? 'strong blue-france' : 'fr-hint-text';
        const scoreOfMonth = monthScore[month.monthName]
        return (
          <div key={index} className={withBoldPresentation}>
            {getMonthName(month.month - 1)}
            <span className='month-monthScore'>
              {((scoreOfMonth === 0 ) || (scoreOfMonth === undefined)) ? '' : ` (${scoreOfMonth})`}
            </span>
          </div>
        )})
      }
    </div>
  )
}
export default MonthColumn;