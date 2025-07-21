import React, { useEffect, useState } from 'react';


export default function SchoolList({
  schools,
  removeSchoolFromList
}) {
  return(
    <ul className='fr-badges-group'>
      {schools.map(school =>  {
        console.log('school', school);
        let schoolName = school.name;
        if (school.qpv) {
          schoolName += ' [QPV]';
        }
        if (school.rep_kind === 'rep') {
          schoolName += ` [REP]`;
        } else if (school.rep_kind === 'rep_plus'){
          schoolName += ` [REP+]`;
        }
        return(
        <li key={`school-${school.id}`}>
          <div className='fr-badge fr-badge--info fr-badge--sm fr-badge--no-icon'>
            {schoolName}
            <span
              className="fr-link__icon fr-icon-delete-line fr-icon--sm fr-ml-1v"
              onClick={() => {
                removeSchoolFromList(school.id);
              }}>
            </span>
          </div>
        </li>
      )
      })}
    </ul>
  )
};