import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  preview(event) {
    const input = event.target
    const previewContainer = document.querySelector('.fr-upload-preview')
    
    if (input.files && input.files[0]) {
      const reader = new FileReader()
      
      reader.onload = function(e) {
        if (previewContainer) {
          previewContainer.innerHTML = `<img src="${e.target.result}" alt="Aperçu de la signature" class="img-fluid" style="max-height: 192px;">`
        }
      }
      
      reader.readAsDataURL(input.files[0])
    }
  }
}