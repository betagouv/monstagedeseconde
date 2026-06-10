import { Controller } from "stimulus";
import { toggleHideContainer } from "../utils/dom";

export default class extends Controller {
  static targets = ["groupNamePublic", "selectGroupName", "sectorBlock"];

  static values = {
    newRecord: Boolean,
    isEntreprisePublic: Boolean,
    fonctionPubliqueSectorId: Number,
  };

  connect() {
    this.sectorSelect = document.querySelector(".sector_list");
    // référence à l'option "Fonction publique" pour pouvoir l'activer/désactiver
    this.fonctionPubliqueOption = this.findFonctionPubliqueOption();
    this.publicPrivateAction(this.isEntreprisePublicValue);
  }

  findFonctionPubliqueOption() {
    if (!this.sectorSelect || !this.hasFonctionPubliqueSectorIdValue) return null;
    return Array.from(this.sectorSelect.options).find(
      (option) => option.value === String(this.fonctionPubliqueSectorIdValue)
    );
  }

  handleClickIsPublic(event) {
    const isPublic = event.target.value === "true";
    this.toggleGroupNames(isPublic);
    this.publicPrivateAction(isPublic);
  }

  publicPrivateAction(isPublic) {
    isPublic ? this.applyPublic() : this.applyPrivate();
  }

  // Structure publique : ministère requis, secteur libre (y compris "Fonction publique")
  applyPublic() {
    this.isEntreprisePublicValue = true;

    const ministry = document.querySelector("#ministry-block");
    const entrepriseGroup = document.querySelector("#group-choice");
    if (ministry) ministry.classList.remove("fr-hidden");
    if (entrepriseGroup) entrepriseGroup.setAttribute("required", "true");

    this.showSectorBlock();
    this.enableFonctionPubliqueOption();
  }

  // Structure privée : ministère masqué/reset, secteur libre sauf "Fonction publique"
  applyPrivate() {
    this.isEntreprisePublicValue = false;

    const ministrySelect = document.querySelector("#group-choice");
    const ministryBlock = document.querySelector("#ministry-block");
    if (ministrySelect) {
      ministrySelect.value = "";
      ministrySelect.required = false;
    }
    if (ministryBlock) ministryBlock.classList.add("fr-hidden");

    this.showSectorBlock();
    this.disableFonctionPubliqueOption();
  }

  showSectorBlock() {
    this.sectorBlockTarget.classList.remove("fr-hidden");
    this.sectorBlockTarget.removeAttribute("hidden");
    toggleHideContainer(this.sectorBlockTarget, true);
    if (this.sectorSelect) this.sectorSelect.required = true;
  }

  enableFonctionPubliqueOption() {
    if (!this.fonctionPubliqueOption) return;
    this.fonctionPubliqueOption.disabled = false;
    this.fonctionPubliqueOption.hidden = false;
  }

  disableFonctionPubliqueOption() {
    if (!this.fonctionPubliqueOption || !this.sectorSelect) return;
    // si "Fonction publique" était sélectionnée, on remet le choix à zéro
    if (this.sectorSelect.value === this.fonctionPubliqueOption.value) {
      this.sectorSelect.value = "";
    }
    this.fonctionPubliqueOption.disabled = true;
    this.fonctionPubliqueOption.hidden = true;
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
}
