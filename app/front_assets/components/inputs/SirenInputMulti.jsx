import React, { useEffect, useState } from "react";
import { useDebounce } from "use-debounce";
import Downshift from "downshift";
import { fetch } from "whatwg-fetch";
import { endpoints } from "../../utils/api";
import {
  setValueById,
  toggleHideContainers,
  toggleHideContainerById,
} from "../../utils/dom";

export default function SirenInputMulti({
  resourceName,
  currentSiret,
  railsEnv,
  newRecord,
}) {
  const [siret, setSiret] = useState(currentSiret || "");
  const [searchResults, setSearchResults] = useState([]);
  const [debouncedSiret, setDebouncedSiret] = useState(siret);
  const [employerNameStr, setEmployerNameStr] = useState(currentSiret || "");

  const inputChange = (event) => {
    setSiret(event.target.value);
    setEmployerNameStr(event.target.value);
  };

  const searchCompanyBySiret = (siret) => {
    fetch(endpoints.searchCompanyBySiret({ siret }))
      .then((response) => response.json())
      .then((json) => {
        if (json.etablissement !== undefined) {
          setSearchResults([json.etablissement]);
        } else {
          setSearchResults([]);
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
          setSearchResults([]);
        }
      })
      .catch((err) => {
        toggleHideContainerById("siren-error", true);
      });
  };

  const siretPresentation = (siret) => {
    return siret.replace(/(\d{3})(\d{3})(\d{3})(\d{5})/, "$1 $2 $3 $4");
  };

  const isAValidSiret = (siret) => {
    if (siret.length != 14 || isNaN(siret)) {
      return false;
    }

    // le SIRET est un numérique à 14 chiffres dont le dernier chiffre est une clef de LUHN.
    let sum = 0;
    let tmp;
    for (let index = 0; index < siret.length; index++) {
      tmp = parseInt(siret.charAt(index), 10);
      if (index % 2 == 0) {
        tmp *= 2;
        tmp = tmp > 9 ? tmp - 9 : tmp;
      }
      sum += tmp;
    }
    return sum % 10 === 0;
  };

  const onChange = (selection) => {
    show_form(true);
    
    const zipcode = selection.adresseEtablissement.codePostalEtablissement;
    const city = selection.adresseEtablissement.libelleCommuneEtablissement;
    const street = `${selection.adresseEtablissement.numeroVoieEtablissement || ''} ${selection.adresseEtablissement.typeVoieEtablissement || ''} ${selection.adresseEtablissement.libelleVoieEtablissement || ''}`.trim();
    const addressConcatenated = `${street} ${zipcode} ${city}`.trim();
    const employerName = selection.uniteLegale.denominationUniteLegale;
    setEmployerNameStr(employerName);

    // Helper function to safely set value
    const setValueSafely = (id, value) => {
      const element = document.getElementById(id);
      if (element) {
        element.value = value || '';
        return true;
      }
      return false;
    };

    // Set values for MultiCoordinator - use setTimeout with retry logic
    const setValues = (retries = 10) => {
      const fields = [
        { id: `${resourceName}_siret`, value: selection.siret },
        { id: `${resourceName}_presentation_siret`, value: siretPresentation(selection.siret) },
        { id: `${resourceName}_employer_name`, value: employerName },
        { id: `${resourceName}_employer_chosen_name`, value: employerName },
        { id: `${resourceName}_employer_address`, value: addressConcatenated },
        { id: `${resourceName}_employer_chosen_address`, value: addressConcatenated },
        { id: `${resourceName}_city`, value: city },
        { id: `${resourceName}_zipcode`, value: zipcode },
        { id: `${resourceName}_street`, value: street }
      ];

      const results = fields.map(field => ({
        id: field.id,
        found: !!document.getElementById(field.id),
        set: setValueSafely(field.id, field.value)
      }));

      const allSet = results.every(r => r.found && r.set);

      if (!allSet && retries > 0) {
        // Retry after a short delay if some elements are not found
        setTimeout(() => setValues(retries - 1), 50);
      } else if (!allSet) {
        // Log which fields couldn't be set for debugging
        const missingFields = results.filter(r => !r.found);
        if (missingFields.length > 0) {
          console.warn('Could not find fields:', missingFields.map(f => f.id));
          console.log('Available fields with similar names:', 
            Array.from(document.querySelectorAll('input, select, textarea'))
              .map(el => el.id)
              .filter(id => id && id.includes(resourceName))
          );
        }
      }
    };

    setTimeout(() => setValues(), 100);

    // Set code APE if available (for sector mapping)
    if (selection.codeApe) {
      // Try to find sector by code APE or set it manually
      // This would require an API call to map code APE to sector_id
      // For now, we'll leave it empty and let the user select
    }
  };

  const clearImmediate = () => {
    setEmployerNameStr('');
    setSiret("");
    setSearchResults([]);
    setValueById(`${resourceName}_siret`, "");
    setValueById(`${resourceName}_presentation_siret`, "");
    setValueById(`${resourceName}_employer_name`, "");
    setValueById(`${resourceName}_employer_chosen_name`, "");
    setValueById(`${resourceName}_employer_address`, "");
    setValueById(`${resourceName}_employer_chosen_address`, "");
    setValueById(`${resourceName}_city`, "");
    setValueById(`${resourceName}_zipcode`, "");
    setValueById(`${resourceName}_street`, "");
    show_form(false);
  };

  const show_form = (show) => {
    toggleHideContainers(document.querySelectorAll(".bloc-tooggle"), show);
  };

  const hide_siret_input = () => {
    // toggleHideContainerById("multi_coordinator_siret_block", true);
    // hide with class fr-hidden
    const element = document.querySelector(".multi_coordinator_siret_block");
    if (element) {
      element.classList.add("fr-hidden");
    }
  };

  useEffect(() => {
    const timerId = setTimeout(() => {
      setDebouncedSiret(siret);
    }, 600); // 600 ms

    return () => {
      clearTimeout(timerId);
    };
  }, [siret]);

  useEffect(() => {
    const errorElement = document.getElementById("siren-error");
    if (errorElement) {
      errorElement.classList.add("fr-hidden");
    }

    const cleanSiret = siret.replace(/\s/g, "");
    const cleanSiretIsNumeric = /^\d{2,}$/.test(cleanSiret);
    if (isAValidSiret(cleanSiret)) {
      searchCompanyBySiret(cleanSiret);
    } else if (cleanSiretIsNumeric) {
      setSearchResults([]);
    } else if (siret.length > 2) {
      searchCompanyByName(siret);
    }
  }, [debouncedSiret]);

  // initialization
  useEffect(() => {
    show_form(!newRecord);
  }, []);

  return (
    <div className="form-group" id="input-siren-multi">
      <div className="container-downshift">
        <Downshift
          onChange={onChange}
          itemToString={(item) => (item ? item.value : "")}
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
                  className: "fr-label",
                  htmlFor: `${resourceName}_siren`,
                })}
              >
                Indiquez le nom ou le SIRET du coordinateur *
                { railsEnv === "development"
                  ? " (dev only : 21950572400209)"
                  : "" }
              </label>
              <div className="d-flex flew-row">
                <div className="input-group input-siren">
                  <input
                    {...getInputProps({
                      onChange: inputChange,
                      value: employerNameStr,
                      className: "fr-input",
                      maxLength: 140,
                      id: `${resourceName}_siren`,
                      placeholder:
                        "Rechercher par nom ou par SIRET(14 caractères)",
                      name: `${resourceName}[siren]`,
                    })}
                  />
                </div>
                <div>
                  <button 
                    type="button"
                    className="fr-btn fr-btn--secondary fr-icon-delete-line"
                    onClick={clearImmediate}>
                  </button>
                </div>
              </div>
              <div className="mt-2 d-flex align-items-center">
                <small>
                  <span
                    className="fr-icon-info-fill text-blue-info"
                    aria-hidden="true"
                  ></span>
                </small>
                <small className="text-blue-info fr-mx-1w">
                  Structure introuvable ?
                </small>
                <a
                  href="#manual-input"
                  className="small text-blue-info"
                  onClick={(e) => {
                    e.preventDefault();
                    show_form(true);
                    hide_siret_input();
                  }}
                >
                  Ajouter votre structure manuellement
                </a>
              </div>
              <div
                className="alerte alert-danger siren-error p-2 mt-2 fr-hidden"
                id="siren-error"
                role="alert"
              >
                <small>Aucune réponse trouvée, essayez avec le SIRET.</small>
              </div>
              <div>
                <div className="search-in-sirene bg-white shadow">
                  <ul
                    {...getMenuProps({
                      className: "p-0 m-0",
                    })}
                  >
                    {isOpen
                      ? searchResults.map((item, index) => (
                          <li
                            {...getItemProps({
                              className: `fr-px-2w fr-py-2w listview-item ${
                                highlightedIndex === index
                                  ? "highlighted-listview-item"
                                  : ""
                              }`,
                              key: index,
                              index,
                              item,
                              style: {
                                fontWeight:
                                  highlightedIndex === index
                                    ? "bold"
                                    : "normal",
                              },
                            })}
                          >
                            <p className="fr-my-0 text-dark font-weight-bold">
                              {item.uniteLegale.denominationUniteLegale}
                            </p>
                            <p className="fr-my-0 fr-text--sm text-dark">
                              {item.activite}
                            </p>
                            <p className="fr-my-0 fr-text--sm text-dark">
                              {
                                item.adresseEtablissement
                                  .adresseCompleteEtablissement
                              }
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
  );
}

