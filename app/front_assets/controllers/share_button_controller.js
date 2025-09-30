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

  showFeedback() {
    // Hide the button
    this.buttonTarget.style.display = 'none';
    
    const successSpan = document.createElement('span');
    successSpan.innerHTML = '<span class="fr-icon-clipboard-line" aria-hidden="true"></span> Lien copié !';
    successSpan.classList.add('fr-text--sm', 'copied-success');
    successSpan.style.marginLeft = '0.5rem';
    
    // Insert span after the button
    this.buttonTarget.parentNode.insertBefore(successSpan, this.buttonTarget.nextSibling);
    
    // Restore button and remove span after 2 seconds
    setTimeout(() => {
      this.buttonTarget.style.display = '';
      if (successSpan && successSpan.parentNode) {
        successSpan.parentNode.removeChild(successSpan);
      }
    }, 2000)
  }

}