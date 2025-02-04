import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = []

  connect() {
    try {
      const educonnectLogout = this.element.querySelector('.educonnect-logout')
      if (educonnectLogout) {
        console.log("Déconnexion EduConnect trouvée, tentative de déconnexion...")
        
        // Si c'est un lien (<a>)
        if (educonnectLogout.tagName === 'A') {
          window.location.href = educonnectLogout.href
        }
        // Si c'est un bouton dans un formulaire
        else if (educonnectLogout.form) {
          educonnectLogout.form.submit()
        }
        // Si c'est un bouton avec une URL de données
        else if (educonnectLogout.dataset.url) {
          window.location.href = educonnectLogout.dataset.url
        }
      } else {
        console.warn("L'élément de déconnexion EduConnect n'a pas été trouvé")
      }
    } catch (error) {
      console.error("Erreur lors de la déconnexion EduConnect:", error)
    }
  }
}
