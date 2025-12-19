import React, { useEffect, useState } from "react";
import Downshift from "downshift";
import { fetch } from "whatwg-fetch";
import { endpoints } from "../../utils/api";
import {
  setValueById,
  toggleHideContainers,
  toggleHideContainerById,
} from "../../utils/dom";

export default function SireneCorporation({
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

  const isAValidSiret = (siret) => {
    if (siret.length != 14 || isNaN(siret)) {
      return false;
    }
    // Luhn algorithm
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

    const setValueSafely = (id, value) => {
      const element = document.getElementById(id);
      if (element) {
        element.value = value || '';
        // Dispatch event for potential listeners (like Stimulus)
        element.dispatchEvent(new Event('input', { bubbles: true }));
        element.dispatchEvent(new Event('change', { bubbles: true }));
        return true;
      }
      return false;
    };

    const setValues = (retries = 10) => {
      const fields = [
        { id: `${resourceName}_siret`, value: selection.siret },
        { id: `${resourceName}_corporation_name`, value: employerName },
        // Adresse du siège
        { id: `${resourceName}_corporation_address`, value: addressConcatenated },
        // Adresse détaillée (nouveaux champs)
        { id: `${resourceName}_corporation_street`, value: street },
        { id: `${resourceName}_corporation_zipcode`, value: zipcode },
        { id: `${resourceName}_corporation_city`, value: city }
      ];

      const results = fields.map(field => ({
        id: field.id,
        found: !!document.getElementById(field.id),
        set: setValueSafely(field.id, field.value)
      }));

      const allSet = results.every(r => r.found && r.set);

      if (!allSet && retries > 0) {
        setTimeout(() => setValues(retries - 1), 50);
      }
    };

    setTimeout(() => setValues(), 100);
  };

    const clearImmediate = () => {
    setEmployerNameStr('');
    setSiret("");
    setSearchResults([]);
    // Clear fields
    const fields = [
      `${resourceName}_siret`,
      `${resourceName}_corporation_name`,
      `${resourceName}_corporation_address`,
      `${resourceName}_corporation_street`,
      `${resourceName}_corporation_zipcode`,
      `${resourceName}_corporation_city`
    ];
    
    fields.forEach(id => {
      const el = document.getElementById(id);
      if (el) el.value = "";
    });
    
    show_form(false);
  };

  const show_form = (show) => {
    toggleHideContainers(document.querySelectorAll(".bloc-tooggle"), show);
  };

  useEffect(() => {
    const timerId = setTimeout(() => {
      setDebouncedSiret(siret);
    }, 600);
    return () => clearTimeout(timerId);
  }, [siret]);

  useEffect(() => {
    const errorElement = document.getElementById("siren-error");
    if (errorElement) errorElement.classList.add("fr-hidden");

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
                Indiquez le nom ou le SIRET d'une structure accueillante *
                { railsEnv === "development" ? " (dev only : 21950572400209)" : "" }
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
                      placeholder: "Rechercher par nom ou par SIRET",
                      name: `${resourceName}[siren]`,
                    })}
                  />
                </div>
                <div>
                  <button 
                    type="button"
                    className="fr-btn fr-btn--secondary fr-icon-delete-line"
                    onClick={clearImmediate}
                    title="Effacer la recherche"
                  >
                  </button>
                </div>
              </div>
              
              <div className="mt-2 d-flex align-items-center">
                <small><span className="fr-icon-info-fill text-blue-info" aria-hidden="true"></span></small>
                <small className="text-blue-info fr-mx-1w">Structure introuvable ?</small>
                <a
                  href="#manual-input"
                  className="small text-blue-info"
                  onClick={(e) => { e.preventDefault(); show_form(true); }}
                >
                  Ajouter votre structure manuellement
                </a>
              </div>

              <div className="alerte alert-danger siren-error p-2 mt-2 fr-hidden" id="siren-error" role="alert">
                <small>Aucune réponse trouvée, essayez avec le SIRET.</small>
              </div>

              <div>
                <div className="search-in-sirene bg-white shadow">
                  <ul {...getMenuProps({ className: "p-0 m-0" })}>
                    {isOpen ? searchResults.map((item, index) => (
                      <li
                        {...getItemProps({
                          className: `fr-px-2w fr-py-2w listview-item ${highlightedIndex === index ? "highlighted-listview-item" : ""}`,
                          key: index,
                          index,
                          item,
                          style: { fontWeight: highlightedIndex === index ? "bold" : "normal" },
                        })}
                      >
                        <p className="fr-my-0 text-dark font-weight-bold">
                          {item.uniteLegale.denominationUniteLegale}
                        </p>
                        <p className="fr-my-0 fr-text--sm text-dark">
                          {item.adresseEtablissement.adresseCompleteEtablissement}
                        </p>
                      </li>
                    )) : null}
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
