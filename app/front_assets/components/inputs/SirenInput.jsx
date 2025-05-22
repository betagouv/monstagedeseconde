import React, { useEffect, useState } from "react";
import { useDebounce } from "use-debounce";
// import { throttle, debounce } from "throttle-debounce";
import Downshift from "downshift";
import { fetch } from "whatwg-fetch";
import { endpoints } from "../../utils/api";
import { employerNameChanged, broadcast } from "../../utils/events";
import {
  setValueById,
  toggleContainer,
  toggleContainers,
  toggleContainerById,
} from "../../utils/dom";

// see: https://geo.api.gouv.fr/adresse
export default function SirenInput({
  resourceName,
  currentSiret,
  railsEnv,
  newRecord,
  currentManualEnter,
  onSubmitError,
  lastPublicValue
}) {
  const [siret, setSiret] = useState(currentSiret || "");
  const [searchResults, setSearchResults] = useState([]);
  const [debouncedSiret, setDebouncedSiret] = useState(siret);
  const [employerNameStr, setEmployerNameStr] = useState(currentSiret);
  const [internshipAddressManualEnter, setInternshipAddressManualEnter] =
    useState(currentManualEnter || false);
  const [isFaulty, setFaulty] = useState(onSubmitError || false);
  const [formerPublicValue, setFormerPublicValue] = useState(lastPublicValue || false);

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
        toggleContainerById("siren-error", true);
      });
  };

  const siretPresentation = (siret) => {
    return siret.replace(/(\d{3})(\d{3})(\d{3})(\d{5})/, "$1 $2 $3 $4");
  };

  const searchCoordinatesByAddress = (fullAddress) => {
    const coordinates = `${resourceName}_entreprise_coordinates`;
    const selector_lon = `${coordinates}_longitude`;
    const selector_lat = `${coordinates}_latitude`;
    fetch(endpoints.apiSearchAddress({ fullAddress }))
      .then((response) => response.json())
      .then((json) => {
        document.getElementById(selector_lon).value =
          json.features[0].geometry.coordinates[0];
        document.getElementById(selector_lat).value =
          json.features[0].geometry.coordinates[1];
      });
  };

  const openManual = (event) => {
    event.preventDefault();
    setOpenManual();
  };

  const setOpenManual = () => {
    setInternshipAddressManualEnter(true);
    toggleContainers(document.querySelectorAll(".bloc-tooggle"), true);
    setValueById(`${resourceName}_internship_address_manual_enter`, true);
    toggleContainers(document.querySelectorAll(".show-when-manual"), true);
    toggleContainers(document.querySelectorAll(".hide-when-manual"), false);

    const labelEntrepriseName = document.querySelector( `label[for='${resourceName}_employer_name']` );
    labelEntrepriseName.innerHTML = "Saisissez le nom (raison sociale) de votre établissement *";
    const inputEntrepriseName = document.getElementById( `${resourceName}_employer_name` );
    inputEntrepriseName.required = true;
    inputEntrepriseName.removeAttribute("readonly");
    // hide the ministry choice block
    const ministry = document.getElementById("ministry-choice");
    ministry.hidden = true;

    const labelEntrepriseAddress = document.querySelector( `label[for='${resourceName}_entreprise_chosen_full_address']` );
    labelEntrepriseAddress.innerHTML = "Saisissez l'adresse du siège de votre établissement *";
    const inputEntrepriseAddress = document.getElementById( `${resourceName}_entreprise_chosen_full_address` );
    inputEntrepriseAddress.required = true;
    inputEntrepriseAddress.removeAttribute("readonly");
    inputEntrepriseName.addEventListener('keyup', (event) => {
      broadcast(employerNameChanged({ employerName: event.target.value }));
    });
  }

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
    // is_public is known when user searched by name and unknown when user searched by siret
    const is_public = selection.is_public;
    const zipcode = selection.adresseEtablissement.codePostalEtablissement;
    const city = selection.adresseEtablissement.libelleCommuneEtablissement;
    const street = `${selection.adresseEtablissement.numeroVoieEtablissement} ${selection.adresseEtablissement.typeVoieEtablissement} ${selection.adresseEtablissement.libelleVoieEtablissement} `;
    const addressConcatenated = `${street} ${zipcode} ${city}`.trim();
    searchCoordinatesByAddress(addressConcatenated);
    const employerName = selection.uniteLegale.denominationUniteLegale;
    setEmployerNameStr(employerName);

    setValueById( `${resourceName}_entreprise_full_address`, addressConcatenated );
    setValueById( `${resourceName}_entreprise_chosen_full_address`, addressConcatenated );
    setValueById( `${resourceName}_siret`, selection.siret);
    setValueById( `${resourceName}_presentation_siret`, siretPresentation(selection.siret) );
    setValueById( `${resourceName}_employer_name`, employerName);

    broadcast(employerNameChanged({ employerName }));

    const ministry = document.getElementById("ministry-choice");
    const ministryClassList = ministry.classList;
    const sectorBloc = document.getElementById(`${resourceName}_sector_id-block`);
    const sectorBlocClassList = sectorBloc.classList;
    const sector = document.getElementById(`sector-choice`);
    // TODO pub/sub with broadcasting would be better
    // because both jsx components and stimulus send events to the containers (show/hide)
    ministryClassList.add("d-none"); // default

    if (is_public != undefined) {
      toggleContainerById("public-private-radio-buttons", false);
      if(is_public){
        document.getElementById("entreprise_is_public_true").checked = true;
        ministry.removeAttribute("style");
        ministryClassList.remove("d-none");

        // For public establishments

        sectorBlocClassList.add("d-none");
        // Safely check and select "Fonction publique" option
        if (sector && sector.options) {
          for (let i = 0; i < sector.options.length; i++) {
            if (sector.options[i].text.toLowerCase().includes('fonction publique')) {
              sector.value = sector.options[i].value;
              break;
            }
          }
        }
        // remove required attribute from sector input
        sector.removeAttribute("required");
      } else {
        // For private companies
        document.getElementById("entreprise_is_public_false").checked = true;
        sectorBlocClassList.remove("d-none");
        sector.value = "";
      }
    }
    if (isFaulty && formerPublicValue){
      ministry.removeAttribute("style");
      ministryClassList.remove("d-none");
    }
  };

  const clearImmediate = () => {
    setEmployerNameStr('');
    setSiret("");
    setSearchResults([]);
    setValueById(`${resourceName}_siret`, "");
    setValueById(`${resourceName}_presentation_siret`, "");
    setValueById(`${resourceName}_employer_name`, "");
    setValueById(`${resourceName}_entreprise_full_address`, "");
    setValueById(`${resourceName}_entreprise_chosen_full_address`, "");
    setValueById(`${resourceName}_entreprise_coordinates_longitude`, "");
    setValueById(`${resourceName}_entreprise_coordinates_latitude`, "");
    show_form(false);
    broadcast(employerNameChanged({ employerName: "" }));
  };

  const show_form = (show) => {
    const blocs = document.querySelectorAll(".bloc-tooggle");
    blocs.forEach((bloc) => {
      if (show) {
        bloc.classList.remove("d-none");
      } else {
        bloc.classList.add("d-none");
      }
    });
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
    document.getElementById("siren-error").classList.add("d-none");

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
    if (internshipAddressManualEnter) { setOpenManual(); }
  }, []);

  return (
    <div className="form-group" id="input-siren">
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
                Indiquez le nom ou le SIRET de la structure d'accueil *
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
                  <button className="fr-btn fr-btn--secondary fr-icon-delete-line"
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
                  onClick={openManual}
                >
                  Ajouter votre structure manuellement
                </a>
              </div>
              <div
                className="alerte alert-danger siren-error p-2 mt-2 d-none"
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
