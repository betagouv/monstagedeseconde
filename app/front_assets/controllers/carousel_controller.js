import { Controller } from '@hotwired/stimulus'

// Continuously scrolling logo banner. The pause button is required for
// auto-moving content (WCAG 2.2.2); the scrolling itself and the pauses on
// hover/focus are handled in CSS (see .partners-carousel in pages/home.scss).
export default class extends Controller {
  static targets = ['playButton']

  togglePlay() {
    const paused = this.element.classList.toggle('paused')
    if (this.hasPlayButtonTarget) {
      this.playButtonTarget.textContent = paused ? 'Relancer le défilement' : 'Mettre en pause'
    }
  }
}
