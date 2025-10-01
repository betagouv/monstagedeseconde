import React, { useEffect, useState } from "react";
import { useDebounce } from "use-debounce";
// import { throttle, debounce } from "throttle-debounce";
import Downshift from "downshift";
import { fetch } from "whatwg-fetch";
import { endpoints } from "../../utils/api";
import { employerNameChanged, broadcast } from "../../utils/events";
import {
  setValueById,
  toggleHideContainers,
  toggleHideContainerById,
} from "../../utils/dom";

const setTallyModalSeen = () => {
  const expires = new Date();
  expires.setTime(expires.getTime() + (30 * 24 * 60 * 60 * 1000)); // 30 jours
  document.cookie = `tally_modal_seen=true;expires=${expires.toUTCString()};path=/`;
};

const isTallyModalSeen = () => {
  return document.cookie.includes('tally_modal_seen=true');
};

const resetTallyModalSeen = () => {
  document.cookie = 'tally_modal_seen=;expires=Thu, 01 Jan 1970 00:00:00 UTC;path=/;';
};

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
        toggleHideContainerById("siren-error", true);
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

  const closeModal = () => {
    const modalElement = document.getElementById('manual-input-modal');
    if (modalElement) {
      modalElement.setAttribute('data-fr-opened', 'false');
      modalElement.setAttribute('aria-hidden', 'true');
      modalElement.classList.remove('fr-modal--opened');
      
      // After closing the modal, open the manual input
      setOpenManual();
    }
  };

  // Function to reset the cookie (for tests)
  const resetModalCookie = () => {
    resetTallyModalSeen();
  };

  // Function to handle the Tally form messages
  const handleTallyMessage = (event) => {
    if (event.origin !== 'https://tally.so') return;
    
    if (event.data.type === 'tally.formSubmitted') {
      // The form has been submitted, close the modal
      closeModal();
    }
  };

  // Add the event listener for the Tally messages
  useEffect(() => {
    window.addEventListener('message', handleTallyMessage);
    return () => {
      window.removeEventListener('message', handleTallyMessage);
    };
  }, []);

  const openManual = (event) => {
    event.preventDefault();
    
    // Check if the modal has already been viewed by this visitor
    if (isTallyModalSeen()) {
      // If the modal has already been viewed, open the manual input
      setOpenManual();
      return;
    }
    
    // Open the DSFR modal
    const modalElement = document.getElementById('manual-input-modal');
    if (modalElement) {
      // Use the DSFR method to open the modal
      modalElement.setAttribute('data-fr-opened', 'true');
      modalElement.setAttribute('aria-hidden', 'false');
      modalElement.classList.add('fr-modal--opened');
      
      // Set the cookie to indicate that the modal has been viewed
      setTallyModalSeen();
      
      // Add an event listener to close the modal
      const closeButton = modalElement.querySelector('.fr-link--close');
      if (closeButton) {
        closeButton.addEventListener('click', (e) => {
          e.preventDefault();
          closeModal();
        });
      }
      
      // Close the modal by clicking on the overlay
      modalElement.addEventListener('click', (e) => {
        if (e.target === modalElement) {
          closeModal();
        }
      });
    }
  };

  const setOpenManual = () => {
    setInternshipAddressManualEnter(true);
    toggleHideContainers(document.querySelectorAll(".bloc-tooggle"), true);
    setValueById(`${resourceName}_internship_address_manual_enter`, true);
    toggleHideContainers(document.querySelectorAll(".show-when-manual"), true);
    toggleHideContainers(document.querySelectorAll(".hide-when-manual"), false);

    const labelEntrepriseName = document.querySelector( `label[for='${resourceName}_employer_name']` );
    labelEntrepriseName.innerHTML = "Saisissez le nom (raison sociale) de votre établissement *";
    const inputEntrepriseName = document.getElementById( `${resourceName}_employer_name` );
    const sectorBloc = document.getElementById(`${resourceName}_sector_id-block`);
    inputEntrepriseName.required = true;
    inputEntrepriseName.removeAttribute("readonly");
    // hide the ministry choice block only if not public
    const ministry = document.getElementById("ministry-choice");
    if (!lastPublicValue) {
      ministry.hidden = true;
      sectorBloc.hidden = false;
    } else {
      ministry.removeAttribute("hidden");
      sectorBloc.hidden = true;
    }
    
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
    
    // Set the code APE if available in the selection
    if (selection.codeApe) {
      setCodeApe(selection.codeApe);
    } else {
      console.log('no code APE found');
    }

    broadcast(employerNameChanged({ employerName }));

    const ministry = document.getElementById("ministry-choice");
    const ministryClassList = ministry.classList;
    const sectorBloc = document.getElementById(`${resourceName}_sector_id-block`);
    const sectorBlocClassList = sectorBloc.classList;
    const sector = document.getElementById(`${resourceName}_sector_id`);
    // TODO pub/sub with broadcasting would be better
    // because both jsx components and stimulus send events to the containers (show/hide)
    ministryClassList.add("fr-hidden"); // default

    if (is_public != undefined) {
      toggleHideContainerById("public-private-radio-buttons", false);
      if(is_public){
        document.getElementById("entreprise_is_public_true").checked = true;
        ministry.removeAttribute("style");
        ministryClassList.remove("fr-hidden");
        ministry.removeAttribute("hidden");

        // For public establishments

        sectorBlocClassList.add("fr-hidden");
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
        document.getElementById(`${resourceName}_is_public_false`).checked = true;
        sectorBlocClassList.remove("fr-hidden");
        sector.value = "";
      }
    }
    if (isFaulty && formerPublicValue){
      ministry.removeAttribute("style");
      ministryClassList.remove("fr-hidden");
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
    setValueById(`${resourceName}_code_ape`, "");
    show_form(false);
    broadcast(employerNameChanged({ employerName: "" }));
  };

  const show_form = (show) => {
    toggleHideContainers(document.querySelectorAll(".bloc-tooggle"), show)
    // hide Siren helper
    // toggleHideContainerById("input-siren", show && !newRecord);
  };

  const setCodeApe = (codeApe) => {
    setValueById(`${resourceName}_code_ape`, codeApe);
  }

  useEffect(() => {
    const timerId = setTimeout(() => {
      setDebouncedSiret(siret);
    }, 600); // 600 ms

    return () => {
      clearTimeout(timerId);
    };
  }, [siret]);

  useEffect(() => {
    document.getElementById("siren-error").classList.add("fr-hidden");

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
    if (internshipAddressManualEnter || !newRecord) { setOpenManual(); }
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
                {railsEnv === "development" && (
                  <button
                    type="button"
                    className="btn btn-sm btn-outline-secondary ml-2"
                    onClick={resetModalCookie}
                    title="Réinitialiser le cookie de la modal (dev only)"
                  >
                    Reset Modal
                  </button>
                )}
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
