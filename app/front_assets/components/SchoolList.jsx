import React, { useEffect, useState } from 'react';


export default function SchoolList({
  schools,
  removeSchoolFromList
}) {
  return(
    <ul className='fr-badges-group fr-mb-2w'>
      {schools.map(school => (
        <li key={`school-${school.id}`}>
          <div className='fr-badge fr-badge--sm'>
            {school.name}
            <span
              className="fr-link__icon fr-icon-delete-line fr-icon--sm fr-ml-1v"
              onClick={() => {
                removeSchoolFromList(school.id);
              }}>
            </span>
          </div>
        </li>
      ))}
    </ul>
  )
};