import React, { useEffect, useState } from 'react';
import { isMobile } from '../utils/responsive';
import { endpoints } from '../utils/api';

const InternshipOfferCard = ({
  internshipOffer,
  handleMouseOver,
  handleMouseOut,
  index,
  sendNotification,
  threeByRow
  }) => {

    const [isFavorite, setIsFavorite] = useState(internshipOffer.is_favorite);

    useEffect(() => {
    }, []);

    const addFavorite = (id) => {
    $.ajax({ type: 'POST', url: endpoints.addFavorite({id}), data: { id } })
        .done(fetchDone)
        .fail(fetchFail);
    };

    const removeFavorite = (id) => {
    $.ajax({ type: 'DELETE', url: endpoints.removeFavorite({id}), data: { id } })
        .done(fetchDone)
        .fail(fetchFail);
    };

    const fetchDone = (result) => {
      setIsFavorite(result['is_favorite']);
      sendNotification('Enregistré !');
      return true
    };

    const fetchFail = (xhr, textStatus) => {
      if (textStatus === 'abort') {
        return;
      }
    };

  return (
    <div className={`col-12 fr-my-2w fr-px-2w ${isMobile() ? '' : ((index % 2) == 0) ? '' : 'fr-pr-0-5v'}`}
    key={internshipOffer.id}
    onMouseOver={(e) => handleMouseOver(internshipOffer.id)}
    onMouseOut={handleMouseOut}
    data-internship-offer-id={internshipOffer.id}
    >
      <div className="fr-card fr-enlarge-link fr-card--full-text" data-test-id={internshipOffer.id}>
        <div className="fr-card__body">
          <div className="sector fr-mb-1w fr-text--grey-425">{internshipOffer.sector}</div>
          

          <div className="fr-card__detail fr-mt-1w">
          <div className="fr-card__title">
            <h4>
              <a href={internshipOffer.link}
                className="row-link"
                onClick={(e) => { e.stopPropagation() }}
              ><div className="h5 fr-mb-2w">
                {internshipOffer.title}
              </div>
              </a>
            </h4>
            </div>

            
          </div>

          <div className="fr-card__desc fr-my-1w">
            {(internshipOffer.can_read_employer_name) &&
              (<div className="mr-auto fr-mb-1w">{internshipOffer.employer_name}</div>)
            }
            <div className="fr-text fr-py-1w test-city fr-text--sm fr-text--grey-425">{internshipOffer.city}</div>
          </div>
        </div>
        {/* puts elements at the opposite on a line */}
        <div className="d-flex justify-content-between">
          <ul className="fr-badges-group fr-p-2w">
            <li>
              <div className="fr-tag fr-mr-1w">
                <span className="fr-icon-calendar-line fr-mr-1w"></span>
                {internshipOffer.available_weeks_count}
              </div>
            </li>
            
            {internshipOffer.fits_for_seconde && (
              <li>
                <div className="fr-tag fr-mr-1w">2de</div>
              </li>
            )}
            {internshipOffer.fits_for_troisieme_or_quatrieme && (
              <>
                <li>
                  <div className="fr-tag fr-mr-1w">3e</div>
                </li>
                <li>
                  <div className="fr-tag fr-mr-1w">4e</div>
                </li>
              </>
            )}
          </ul>
          { internshipOffer.logged_in && internshipOffer.can_manage_favorite &&
              <span className={`fr-mx-2w fr-my-2w heart-${isFavorite ? 'full' : 'empty'}`}
                onClick={(e) => { (isFavorite) ? removeFavorite(internshipOffer.id) : addFavorite(internshipOffer.id)}}
              ></span>
            }
        </div>

      </div>
    </div>
  );
};

export default InternshipOfferCard;