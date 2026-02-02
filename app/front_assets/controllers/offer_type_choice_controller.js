import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["alert"];

  connect() {
    this.toggleAlert();
  }

  toggleAlert() {
    const multiCompanyRadio = this.element.querySelector('input[value="for_multiple_companies"]');
    const isMultiCompanySelected = multiCompanyRadio && multiCompanyRadio.checked;

    this.alertTargets.forEach((alert) => {
      alert.classList.toggle("fr-hidden", !isMultiCompanySelected);
    });
  }
}
