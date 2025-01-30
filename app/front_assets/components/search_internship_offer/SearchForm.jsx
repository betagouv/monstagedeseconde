import React from 'react';
import CityInput from './CityInput';
import KeywordInput from './KeywordInput';

const SearchForm = ({ defaultValues, onSearch }) => {
  const handleSubmit = (e) => {
    e.preventDefault();
    const formData = new FormData(e.target);
    const searchParams = Object.fromEntries(formData);
    onSearch(searchParams);
  };

  return (
    <div className="search-offer-bloc fr-px-0 fr-py-2w">
      <form onSubmit={handleSubmit} id="desktop_internship_offers_index_search_form">
        <div className="row">
          <div className="col-md-9">
            <CityInput
              city={defaultValues.city}
              latitude={defaultValues.latitude}
              longitude={defaultValues.longitude}
              radius={defaultValues.radius}
              whiteBg={true}
            />
          </div>
          <div className="col-md-3 d-flex justify-content-end align-items-end">
            <button 
              type="submit" 
              className="fr-btn fr-btn--icon-left fr-icon-search-line"
              title="Lancer la recherche"
            >
              Rechercher
            </button>
          </div>
        </div>
      </form>
    </div>
  );
};

export default SearchForm;