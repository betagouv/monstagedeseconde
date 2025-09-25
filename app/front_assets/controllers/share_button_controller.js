import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "url"]

  connect() {
  }

  copyUrl(event) {
    event.preventDefault()
    event.stopPropagation()
    event.stopImmediatePropagation()

    // Get the url to share
    const urlToShare = this.getUrlToShare()
    
    if (urlToShare) {
      this.copyToClipboard(urlToShare)
      this.showFeedback()
    }

    return false
  }

  getUrlToShare() {
    if (this.data.has("url")) {
      return this.data.get("url")
    }

    if (this.hasUrlTarget) {
      return this.urlTarget.value || this.urlTarget.textContent
    }

    return window.location.href
  }

  async copyToClipboard(text) {
    try {
      // Use the modern clipboard api if available
      if (navigator.clipboard && window.isSecureContext) {
        await navigator.clipboard.writeText(text)
        return true
      } else {
        // Fallback for older browsers
        const textArea = document.createElement("textarea")
        textArea.value = text
        textArea.style.position = "fixed"
        textArea.style.left = "-999999px"
        textArea.style.top = "-999999px"
        document.body.appendChild(textArea)
        textArea.focus()
        textArea.select()
        
        const successful = document.execCommand('copy')
        document.body.removeChild(textArea)
        return successful
      }
    } catch (err) {
      console.error('Erreur lors de la copie:', err)
      return false
    }
  }

}