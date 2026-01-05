import { Controller } from "stimulus";

export default class extends Controller {
  static targets = [
    "form", 
    "submitButton",
    // Signatory fields (Source)
    "employerName", "employerRole", "employerEmail", "employerPhone",
    // Tutor fields (Destination)
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
  }

  copyRepresentative(event) {
    if (event.target.checked) {
      if (this.hasEmployerNameTarget && this.hasTutorNameTarget) {
        this.tutorNameTarget.value = this.employerNameTarget.value;
      }
      if (this.hasEmployerRoleTarget && this.hasTutorRoleTarget) {
        this.tutorRoleTarget.value = this.employerRoleTarget.value;
      }
      if (this.hasEmployerEmailTarget && this.hasTutorEmailTarget) {
        this.tutorEmailTarget.value = this.employerEmailTarget.value;
      }
      if (this.hasEmployerPhoneTarget && this.hasTutorPhoneTarget) {
        this.tutorPhoneTarget.value = this.employerPhoneTarget.value;
      }
    } else {
      this.tutorNameTarget.value = "";
      this.tutorRoleTarget.value = "";
      this.tutorEmailTarget.value = "";
      this.tutorPhoneTarget.value = "";
    }
  }
}
