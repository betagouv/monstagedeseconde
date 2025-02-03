import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = []

  connect() {  
    const educonnectLogout = this.element.querySelector('.educonnect-logout');
    if (educonnectLogout) {
      educonnectLogout.click();
    }
  }
}
