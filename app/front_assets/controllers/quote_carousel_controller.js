import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['quote']
  
  initialize() {
    this.currentIndex = 0
    this.showCurrentQuote()
  }

  next() {
    this.currentIndex = (this.currentIndex + 1) % this.quoteTargets.length
    this.showCurrentQuote()
  }

  previous() {
    this.currentIndex = (this.currentIndex - 1 + this.quoteTargets.length) % this.quoteTargets.length
    this.showCurrentQuote()
  }

  showCurrentQuote() {
    this.quoteTargets.forEach((quote, index) => {
      quote.classList.toggle('hidden', index !== this.currentIndex)
    })
  }
}