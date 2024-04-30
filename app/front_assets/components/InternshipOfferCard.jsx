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
    <div className={`col-${isMobile() ? '11 text-align-center' : (threeByRow ? '4' : '6')} fr-my-2w fr-px-2w ${isMobile() ? '' : ((index % 2) == 0) ? '' : 'fr-pr-0-5v'}`}
    key={internshipOffer.id}
    onMouseOver={(e) => handleMouseOver(internshipOffer.id)}
    onMouseOut={handleMouseOut}
    data-internship-offer-id={internshipOffer.id}
    >
      <div className="fr-card fr-enlarge-link" data-test-id={internshipOffer.id}>
        <div className="fr-card__body">
          <div className="fr-card__content">
            <h4 className="fr-card__title">
              <a href={internshipOffer.link}
                className="row-link text-dark"
                onClick={(e) => { e.stopPropagation() }}
              ><div className="card-title-std-height">
                {internshipOffer.title}
              </div>
              </a>
            </h4>
            <div className="fr-card__detail">
              <div className="mr-auto d-flex align-items-center">
                <span className="fr-icon-arrow-right-line fr-icon--sm fr-mb-0"></span>
                <span className="fr-text fr-px-1w fr-mb-3w fr-mt-2w">Du {internshipOffer.date_start} au {internshipOffer.date_end}</span>
              </div>
              { internshipOffer.logged_in && internshipOffer.can_manage_favorite &&
                <div className={`heart-${isFavorite ? 'full' : 'empty'}`}
                  onClick={(e) => { (isFavorite) ? removeFavorite(internshipOffer.id) : addFavorite(internshipOffer.id)}}
                ></div>
              }
            </div>
            <div className="fr-card__desc">
              {(internshipOffer.can_read_employer_name) &&
                (<div className="mr-auto blue-france fr-mb-6w">{internshipOffer.employer_name}</div>)
              }
            </div>

          </div>
        </div>
        <div className="fr-card__header">
          <div className="fr-card__img">
            <img className="fr-responsive-img img-card-maxima" src={internshipOffer.image} alt="secteur" width="310"/>
          </div>
          <ul className="fr-badges-group">
            <li>
              <div className="fr-badge fr-badge--warning fr-badge--no-icon">{internshipOffer.sector}</div>
            </li>
            <li>
              <div className="fr-badge fr-badge--warning fr-badge--no-icon">{internshipOffer.city}</div>
            </li>
          </ul>
        </div>
      </div>
    </div>
  );
};

export default InternshipOfferCard;