import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = []

  connect() {
    try {
      const educonnectLogout = this.element.querySelector('.educonnect-logout');
      const fimLogout = this.element.querySelector('.fim-logout');
  
      if (educonnectLogout) {
        console.log('Déconnexion EduConnect trouvée, tentative de déconnexion...');
        window.location.href = educonnectLogout.href;
      } else if (fimLogout) {
        console.log('Déconnexion FIM trouvée, tentative de déconnexion...');
        window.location.href = fimLogout.href;
      } else {
        console.warn('L\'élément de déconnexion n\'a pas été trouvé');
      }
    } catch (error) {
      console.error('Erreur lors de la déconnexion :', error);
    }
  }
}

