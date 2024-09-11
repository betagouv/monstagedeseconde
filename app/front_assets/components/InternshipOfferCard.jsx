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
          <div className="sector">{internshipOffer.sector}</div>
          

          <div className="fr-card__detail fr-mt-1w">
          <h4 className="fr-card__title">
            <a href={internshipOffer.link}
              className="row-link text-dark"
              onClick={(e) => { e.stopPropagation() }}
            ><div className="card-title-std-height">
              {internshipOffer.title}
            </div>
            </a>
          </h4>
            { internshipOffer.logged_in && internshipOffer.can_manage_favorite &&
              <div className={`heart-${isFavorite ? 'full' : 'empty'}`}
                onClick={(e) => { (isFavorite) ? removeFavorite(internshipOffer.id) : addFavorite(internshipOffer.id)}}
              ></div>
            }
          </div>

          <div className="fr-card__desc fr-my-1w">
            {(internshipOffer.can_read_employer_name) &&
              (<div className="mr-auto blue-france fr-mb-1w">{internshipOffer.employer_name}</div>)
            }
            <div className="fr-text fr-py-1w">{internshipOffer.city}</div>
          </div>
        </div>

        <div className="ftets">
          <ul className="fr-badges-group fr-p-2w">
            <li>
              <div className="fr-badge fr-badge--no-icon">
                <span className="fr-icon-calendar-line fr-mr-1w"></span>
                1 semaine disponible
              </div>
            </li>
            <li>
              <div className="fr-badge fr-badge--no-icon">4ème</div>
            </li>
            <li>
              <div className="fr-badge fr-badge--no-icon">3ème</div>
            </li>
          </ul>
        </div>

      </div>
    </div>
  );
};

export default InternshipOfferCard;