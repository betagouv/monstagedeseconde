import { Controller } from 'stimulus';

// Stage partagé : affiche/masque le second jeu d'horaires (seconde période) selon la
// case « Je souhaite ajouter des horaires différents pour la seconde période ». Quand
// on décoche, on vide les sélecteurs de la période 2 pour ne pas soumettre d'horaires
// résiduels (le builder retombe alors sur les horaires de la première période).
export default class extends Controller {
  static targets = ['toggle', 'container'];

  toggle() {
    if (this.toggleTarget.checked) {
      this.containerTarget.classList.remove('d-none');
    } else {
      this.containerTarget.classList.add('d-none');
      this.clearInputs();
    }
  }

  clearInputs() {
    this.containerTarget.querySelectorAll('select').forEach((select) => {
      select.value = '';
    });
  }
}
