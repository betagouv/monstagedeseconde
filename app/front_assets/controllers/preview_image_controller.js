import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview"]
  

  preview(event) {
    const input = event.target
    const previewContainer = document.querySelector('.fr-upload-preview')
    
    if (input.files && input.files[0]) {
      const reader = new FileReader()
      
      reader.onload = (e) => {
        if (previewContainer) {
          previewContainer.innerHTML = `<img src="${e.target.result}" alt="Aperçu de la signature" class="img-fluid" style="max-height: 192px;">`
        }
      }
      
      reader.readAsDataURL(input.files[0])
    }
  }

  clear(event) {
    event.preventDefault()
    const input = this.inputTarget
    const previewContainer = document.querySelector('.fr-upload-preview')
    
    if (input) {
      input.value = ''
    }
    
    if (previewContainer) {
      previewContainer.innerHTML = ''
    }
  }
}