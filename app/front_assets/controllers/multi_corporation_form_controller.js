import { Controller } from "stimulus";

export default class extends Controller {
  static targets = [
    "form", 
    "submitButton",
    // Signatory fields
    "signatoryName", "signatoryRole", "signatoryEmail", "signatoryPhone",
    // Tutor fields
    "tutorName", "tutorRole", "tutorEmail", "tutorPhone"
  ];

  connect() {
    console.log("MultiCorporationForm connected");
  }

  add(event) {
    // Standard form submission handled by Turbo
  }

  reset() {
    this.formTarget.reset();
    const toggles = document.querySelectorAll('.bloc-tooggle');
    toggles.forEach(el => el.classList.add('fr-hidden'));
    
    // Reset hidden fields
    this.formTarget.querySelectorAll('input[type="hidden"]').forEach(input => {
      if (input.name.includes('[multi_multi_corporation_id]')) return; 
      input.value = '';
    });
    
    // Uncheck copy checkbox
    const checkbox = document.getElementById('copy-rep-infos');
    if (checkbox) checkbox.checked = false;

    // Reset React component state via DOM event or direct access if possible
    // Since we can't easily access React state from here, we rely on the "reset" button in React or just hiding the form
  }

  copyRepresentative(event) {
    if (event.target.checked) { 
    }
  }
}
