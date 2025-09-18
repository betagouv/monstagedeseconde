import { Controller } from "stimulus";
import { toggleHideContainer } from "../utils/dom";

export default class extends Controller {
  static targets = ["groupNamePublic", "selectGroupName", "sectorBlock"];

  static values = {
    newRecord: Boolean,
    isEntreprisePublic: Boolean,
  };

  handleClickIsPublic(event) {
    const isPublic = event.target.value === "true";
    this.toggleGroupNames(isPublic);
    this.publicPrivateAction(isPublic);
  }

  publicPrivateAction(isPublic) {
    isPublic
      ? this.selectPublicSectorAndHide()
      : this.selectPrivateSectorAndShow();
  }

  selectPublicSectorAndHide() {
    // set public state
    this.isEntreprisePublicValue = true;

    // MINISTRY
    // show the ministry choice block
    this.groupNamePublicTarget.classList.remove("fr-hidden");
    this.groupNamePublicTarget.removeAttribute("hidden");

    // set required to true to the entreprise_group_id
    const entrepriseGroup = document.querySelector("#group-choice");
    if (entrepriseGroup) {
      entrepriseGroup.required = true;
    }

    // SECTOR
    // set required to false to the sector_id
    const selectElement = document.querySelector(".sector_list");
    if (selectElement) {
      selectElement.required = false;
    }

    // hide the sector choice block
    toggleHideContainer(this.sectorBlockTarget, false);
  }

  selectPrivateSectorAndShow() {
    // set public state
    this.isEntreprisePublicValue = false;
    // set ministry group to '' and required to false
    const ministryGroup = document.querySelector("#group-choice");
    if (ministryGroup) {
      ministryGroup.value = "";
      ministryGroup.required = false;
    }

    // show the sector choice block
    this.sectorBlockTarget.classList.remove("fr-hidden");
    this.sectorBlockTarget.removeAttribute("hidden");

    // set required to true to the sector_id
    const sectorChoice = document.querySelector("#sector_id");
    if (sectorChoice) {
      sectorChoice.required = true;
      sectorChoice.value = "";
    }
    // show the sector choice block
    toggleHideContainer(this.sectorBlockTarget, true);
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
    toggleHideContainer(this.groupNamePublicTarget, false);
    if (isPublic) {
      this.isElementLoaded(
        'div[data-ministry-fields-target="groupNamePublic"]'
      ).then((element) => {
        toggleHideContainer(this.groupNamePublicTarget, true);
      });
    }
  }

  groupNamePublicTargetConnected(element) {
    this.toggleGroupNames(!!this.isEntreprisePublicValue);
  }

  connect() {
    this.publicPrivateAction(this.isEntreprisePublicValue);
  }
}
