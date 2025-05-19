import React from 'react';
import veloTandem from '../images/velo-tandem.png';


const ImmersionFaciliteeCard = () => (
  <div className="fr-callout fr-mb-4w d-flex align-items-center immersion-facilitee-card" style={{ background: '#e5fbfd' }}>
    <div className="flex-grow-1">
      <p className="fr-callout__title mb-2" style={{ color: '#009099' }}>
        Vous ne trouvez pas l’offre idéale ?
      </p>
      <p className="mb-2" style={{ color: '#009099' }}>
        Recherchez parmi 40 000 entreprises accueillantes<br />
        et postulez en un clic sur Immersion Facilitée.
      </p>
      <a
        href="https://immersion-facile.beta.gouv.fr/recherche-scolaire?mtm_campaign=1E1S"
        target="_blank"
        rel="noopener noreferrer"
        className="fr-link fr-link--icon-right fr-icon-external-link-line"
        style={{ color: '#009099' }}
      >
        Recherchez sur Immersion Facilitée
      </a>
    </div>
    <div className="d-none d-md-block ms-4">
      <img
        src={veloTandem}
        alt=""
        height="96"
        aria-hidden="true"
      />
    </div>
  </div>
);

export default ImmersionFaciliteeCard;