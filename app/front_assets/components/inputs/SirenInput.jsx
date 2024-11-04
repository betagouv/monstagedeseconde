import React, { useEffect, useState } from 'react';
import { useDebounce } from 'use-debounce';
// import { throttle, debounce } from "throttle-debounce";
import Downshift from 'downshift';
import { fetch } from 'whatwg-fetch';
import { endpoints } from '../../utils/api';

// see: https://geo.api.gouv.fr/adresse
export default function SirenInput({
  resourceName,
  currentSiret,
  railsEnv,
  newRecord,
}) {
  const [siret, setSiret] = useState(currentSiret || '');
  const [searchResults, setSearchResults] = useState([]);
  const [debouncedSiret, setDebouncedSiret] = useState(siret);

  const inputChange = (event) => {
    setSiret(event.target.value);
  };

  const searchCompanyBySiret = (siret) => {
    fetch(endpoints.searchCompanyBySiret({ siret }))
      .then((response) => response.json())
      .then((json) => {
        if (json.etablissement !== undefined) {
          setSearchResults([json.etablissement]);
        } else {
          setSearchResults([])
        }
      });
  };

  const searchCompanyByName = (name) => {
    fetch(endpoints.searchCompanyByName({ name }))
      .then((response) => response.json())
      .then((json) => {
        if (json.etablissements !== undefined) {
          setSearchResults(json.etablissements);
        } else {
          setSearchResults([])
        }
      })
      .catch( err => {
        document.getElementById('siren-error').classList.remove('d-none');
      });
  };

  const siretPresentation = (siret) => {
    return siret.replace(/(\d{3})(\d{3})(\d{3})(\d{5})/, '$1 $2 $3 $4');
  }

  const searchCoordinatesByAddress = (fullAddress) => {
    fetch(endpoints.apiSearchAddress({ fullAddress }))
      .then((response) => response.json())
      .then((json) => {
        const coordinates = json.features[0].geometry.coordinates;
        document.getElementById("entreprise_entreprise_coordinates_longitude").value = coordinates[0];
        document.getElementById("entreprise_entreprise_coordinates_latitude").value = coordinates[1];
      });
  };

  // const openManual = (event) => {
  //   event.preventDefault();
  //   const blocs = document.querySelectorAll('.bloc-tooggle');
  //   blocs.forEach(bloc => {
  //     bloc.classList.remove('d-none');
  //   });
  //   const manualBlocs = document.querySelectorAll('.bloc-manual');
  //   manualBlocs.forEach(bloc => {
  //     bloc.classList.remove('d-none');
  //   });
  //   document.querySelector('.fr-callout').classList.add('d-none');
  //   document.getElementById('organisation_city').removeAttribute("readonly");
  //   document.getElementById('organisation_zipcode').removeAttribute("readonly");
  //   document.getElementById("organisation_manual_enter").value = true;
  // }

  const isAValidSiret = (siret) => {
    if ((siret.length != 14) || (isNaN(siret))) { return false; }

    // le SIRET est un numérique à 14 chiffres dont le dernier chiffre est une clef de LUHN.
    let sum = 0;
    let tmp;
    for (let index = 0; index < siret.length; index++) {
      tmp = parseInt(siret.charAt(index), 10)
      if ((index % 2) == 0) {
        tmp *= 2;
        tmp = tmp > 9 ? tmp - 9 : tmp;
      }
      sum += tmp;
    }
    return ((sum % 10) === 0)
  }

  const onChange = (selection) => {
    show_form(true);
    const is_public = selection.is_public;
    const zipcode = selection.adresseEtablissement.codePostalEtablissement;
    const city = selection.adresseEtablissement.libelleCommuneEtablissement;
    const street = `${selection.adresseEtablissement.numeroVoieEtablissement} ${selection.adresseEtablissement.typeVoieEtablissement} ${selection.adresseEtablissement.libelleVoieEtablissement} `;
    const addressConcatenated = (`${street} ${zipcode} ${city}`).trim();
    searchCoordinatesByAddress(addressConcatenated);
    document.getElementById("entreprise_employer_name").value = selection.uniteLegale.denominationUniteLegale;
    document.getElementById("entreprise_entreprise_full_address").value = addressConcatenated;
    document.getElementById("entreprise_entreprise_chosen_full_address").value = addressConcatenated;
    document.getElementById("entreprise_siret").value = selection.siret;
    document.getElementById("entreprise_presentation_siret").value = siretPresentation(selection.siret);
    document.getElementById("entreprise_is_public_true").checked = is_public;
    document.getElementById("entreprise_is_public_false").checked = !is_public;
    document.getElementById("entreprise_group_id")
            .parentNode
            .parentNode
            .classList
            .add(is_public ? 'public' : 'd-none');
  }

  const show_form = (show) => {
    const blocs = document.querySelectorAll('.bloc-tooggle');
    blocs.forEach(bloc => {
      if(show){
        bloc.classList.remove('d-none');
      } else {
        bloc.classList.add('d-none');
      }
    });
  }

  useEffect(() => {
    const timerId = setTimeout(() => {
      setDebouncedSiret(siret);
    }, 750); // 750 ms

    return () => {
      clearTimeout(timerId);
    };
  }, [siret]);

  useEffect(() => {
    document.getElementById('siren-error').classList.add('d-none');

    const cleanSiret = siret.replace(/\s/g, '');
    const cleanSiretIsNumeric = /^\d{2,}$/.test(cleanSiret);
    if (isAValidSiret(cleanSiret)) {
      searchCompanyBySiret(cleanSiret)
    } else if (cleanSiretIsNumeric) {
      setSearchResults([]);
    } else if (siret.length > 2) { // a text;
      searchCompanyByName(siret);
    }
  }, [debouncedSiret]);

  // initialization
  useEffect(() => {
    show_form(!newRecord);
  }), [];


  return (
    <div className="form-group" id="input-siren">
      <div className="container-downshift">
        <Downshift
          onChange={onChange }
          itemToString={item => (item ? item.value : '')}
        >
          {({
            getInputProps,
            getItemProps,
            getLabelProps,
            getMenuProps,
            isOpen,
            inputValue,
            highlightedIndex,
            selectedItem,
            getRootProps,
          }) => (
            <div>
              <label
                {...getLabelProps({
                  className: 'fr-label',
                  htmlFor: `${resourceName}_siren`,
                })}
              >
                Indiquez le nom ou le SIRET de la structure d’accueil*{railsEnv === 'development' ? ' (dev only : 90943224700015)' : ''}
              </label>
              <div className="input-group input-siren">
                <input
                  {...getInputProps({
                    onChange: inputChange,
                    value: currentSiret,
                    className: 'fr-input',
                    maxLength: 140,
                    id: `${resourceName}_siren`,
                    placeholder: 'Rechercher par nom ou par SIRET(14 caractères)',
                    name: `${resourceName}[siren]`
                  })}
                />
              </div>
              {/* <div className='mt-2 d-flex align-items-center'>
                  <small><span className="fr-icon-info-fill text-blue-info" aria-hidden="true"></span></small>
                  <small className="text-blue-info fr-mx-1w">Société introuvable ?</small>
                  <a href='#manual-input' className='pl-2 small text-blue-info' onClick={openManual}>Ajouter une société manuellement</a>
                </div> */}
              <div className="alerte alert-danger siren-error p-2 mt-2 d-none" id='siren-error' role="alert">
                <small>Aucune réponse trouvée, essayez avec le SIRET.</small>
              </div>
              <div>
                <div className="search-in-sirene bg-white shadow">
                  <ul {...getMenuProps({
                      className: 'p-0 m-0',
                    })}
                  >
                    {isOpen
                      ? searchResults.map((item, index) => (
                            <li
                              {...getItemProps({
                                className: `fr-px-2w fr-py-2w listview-item ${
                                  highlightedIndex === index ? 'highlighted-listview-item' : ''
                                }`,
                                key: index,
                                index,
                                item,
                                style: {
                                  fontWeight: highlightedIndex === index? 'bold' : 'normal',
                                },
                              })}
                            >
                              <p className='fr-my-0 text-dark font-weight-bold'>
                                {item.uniteLegale.denominationUniteLegale}
                              </p>
                              <p className='fr-my-0 fr-text--sm text-dark'>
                                {item.activite}
                              </p>
                              <p className='fr-my-0 fr-text--sm text-dark'>
                                {item.adresseEtablissement.adresseCompleteEtablissement}
                              </p>
                            </li>
                      ))
                      : null}
                  </ul>
                </div>
              </div>

            </div>
          )}
        </Downshift>
      </div>
    </div>
  )
}
