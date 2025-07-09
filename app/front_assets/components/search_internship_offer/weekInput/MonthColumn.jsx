import React, { useEffect, useState } from 'react';
import { getMonthName }  from '../../../utils/months';

function MonthColumn({
  monthDetailedList,
  monthScore,
}) {
  return(
    <div className='fr-mt-1v'>
      { monthDetailedList().map((month, index) => {
        const withBoldPresentation = monthScore[month.monthName] > 0 ? 'strong blue-france' : 'silent-month';
        const scoreOfMonth = monthScore[month.monthName]
        return (
          <div key={index} className={withBoldPresentation}>
            {getMonthName(parseInt(month.month - 1, 10))}
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