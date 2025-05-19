import { Controller } from "stimulus";
import $ from "jquery";
import { hide, showSlow, hideElement } from "../utils/dom";

export default class extends Controller {
  static targets = ["groupNamePublic", "selectGroupName"];

  static values = {
    newRecord: Boolean,
    isEntreprisePublic: Boolean,
  };

  handleClickIsPublic(event) {
    const isPublic = event.target.value === "true";
    this.toggleGroupNames(isPublic);
    if (isPublic) {
      this.selectPublicSectorAndHide();
    } else {
      this.selectPrivateSectorAndShow();
    }
  }

  checkIfIsPublic() {
    const publicRadioButton = document.querySelector('.public-radio-button-true');
    const isPublic =  publicRadioButton ? publicRadioButton.checked : false;
    if (isPublic) {
      this.selectPublicSectorAndHide();
    } else {
      this.selectPrivateSectorAndShow();
    }
  }

  selectPublicSectorAndHide() {
    const selectElement = document.querySelector('#sector-choice');
    const option = selectElement.querySelector('option[value="Fonction publique"]');

    if (selectElement) {
      const option = Array.from(selectElement.options).find(option => option.text === 'Fonction publique');
      if (option) {
        option.selected = true;
      }
    }

    // show the ministry choice block
    const ministry = document.getElementById("ministry-choice");
    ministry.hidden = false;
    // set required to true to the entreprise_group_id
    const entrepriseGroup = document.querySelector('#group-choice');
    if (entrepriseGroup) {
      entrepriseGroup.required = true;
    }

    // hide the sector choice block

    const sectorChoiceBlock = document.querySelector('#entreprise_sector_id-block');
    if (sectorChoiceBlock) {
      sectorChoiceBlock.hidden = true;
    }
    if (sectorChoice) {
      sectorChoice.hidden = true;
    }
    // set required to false to the sector-choice
    const sectorChoice = document.querySelector('#sector-choice');
    if (sectorChoice) {
      sectorChoice.required = false;
    }
  }

  selectPrivateSectorAndShow() {
    // set ministry group to '' and required to false
    const ministryGroup = document.querySelector('#group-choice');
    if (ministryGroup) {
      ministryGroup.value = '';
      ministryGroup.required = false;
    }

    // show the sector choice block
    const sectorChoiceBlock = document.querySelector('#entreprise_sector_id-block');
    if (sectorChoiceBlock) {
      sectorChoiceBlock.hidden = false;
    }

    // set required to true to the sector-choice
    const sectorChoice = document.querySelector('#sector-choice');
    if (sectorChoice) {
      sectorChoice.required = true;
      sectorChoice.value = '';
    }
  }

  async isElementLoaded(selector) {
    while (
      document.querySelector(selector) === null &&
      selector.classList.contains("d-none")
    ) {
      await new Promise((resolve) => requestAnimationFrame(resolve));
    }
    return document.querySelector(selector);
  }

  toggleGroupNames(isPublic) {
    this.groupNamePublicTarget.classList.remove("d-none");
    hide($(this.groupNamePublicTarget));
    if (isPublic) {
      this.isElementLoaded('div[data-ministry-fields-target="groupNamePublic"]'
      ).then((element) => {
        showSlow($(this.groupNamePublicTarget));
      });
    }
  }

  groupNamePublicTargetConnected(element) {
    // this.toggleGroupNames(!!this.isEntreprisePublicValue);
  }

  connect() {
    this.checkIfIsPublic(); 
  }
}
