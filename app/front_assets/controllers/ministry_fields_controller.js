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

  selectPublicSectorAndHide() {
    const selectElement = document.querySelector('#sector-choice');
    const option = selectElement.querySelector('option[value="Fonction publique"]');

    if (selectElement) {
      const option = Array.from(selectElement.options).find(option => option.text === 'Fonction publique');
      if (option) {
        option.selected = true;
      }
    }

    const sectorChoiceBlock = document.querySelector('#sector-choice-block');
    if (sectorChoiceBlock) {
      sectorChoiceBlock.hidden = true;
    }
  }

  selectPrivateSectorAndShow() {
    const sectorChoiceBlock = document.querySelector('#sector-choice-block');
    if (sectorChoiceBlock) {
      sectorChoiceBlock.hidden = false;
    }

    const selectElement = document.querySelector('#sector-choice');
    if (selectElement) {
      selectElement.value = '';
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
    console.log("public: " + this.isEntreprisePublicValue);
    this.toggleGroupNames(!!this.isEntreprisePublicValue);
  }
}
