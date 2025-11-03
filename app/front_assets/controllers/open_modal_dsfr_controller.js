import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["modalRoot"];
  static values = { isOpen: Boolean };
  DELAY_MS = 700;

  openModal() {
    dsfr(this.modalRootTarget).modal.disclose();
  }

  closeModal() {
    dsfr(this.modalRootTarget).modal.conceal();
    fetch("/utilisateurs/info-modale-vue", {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ show_modal_info: false })
    });

  }

  connect() {
    setTimeout(() => {
      this.isOpenValue ? this.openModal() : this.closeModal();
    }, this.DELAY_MS);
  }
}
