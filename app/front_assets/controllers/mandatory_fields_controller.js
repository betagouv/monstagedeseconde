import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = [
    'mandatoryField',
    'disabledField'
  ];

  static values = {
    minimumLength: Number
  }
  
  // use it with copying the following line in the html file:
  // --------------------------
  // data-controller="mandatory-fields" data-mandatory-fields-minimum-length-value="3"
  // --------------------------
  // input[ data-mandatory-fields-target="mandatoryField"
  //        data-action="input->mandatory-fields#fieldChange"]
  // or
  // data: { action: "input->mandatory-fields#fieldChange",
  //         :'mandatory-fields-target' => "mandatoryField"}
  // --------------------------
  // input data-mandatory-fields-target="disabledField"
  // or
  // data: { :'mandatory-fields-target' => "disabledField"}

  connect() {
    this.checkFields()
  }

  checkFields() {
    const allFieldsFilled = this.mandatoryFieldTargets.every(field => field.value.length >= this.minimumLengthValue)
    this.disabledFieldTarget.disabled = !allFieldsFilled
  }

  fieldChange(event){
    this.checkValidation();
  }

  areAllMandatoryFieldsFilled(){
    let allMandatoryFieldsAreFilled = true;
    this.mandatoryFieldTargets.forEach((field) => {
      if (field.value.length <= this.minimumLengthValue) {
        allMandatoryFieldsAreFilled = false;
      }
    });
    return allMandatoryFieldsAreFilled;
  }

  // possible values are 'disabled' or 'enabled'
  setDisabledFieldsTo(status){

    const disabledFields = this.disabledFieldTargets;
    disabledFields.forEach((field) => {
      field.disabled =  (status === 'disabled') ;
    });
  }

  checkFields() {
    const allFieldsFilled = this.mandatoryFieldTargets.every(field => field.value.length >= this.minimumLengthValue)
    this.disabledFieldTarget.disabled = !allFieldsFilled
  }

  checkValidation(){
    if(this.areAllMandatoryFieldsFilled()){
      this.setDisabledFieldsTo('enabled');
    } else {
      this.setDisabledFieldsTo('disabled');
    }
  }

  mandatoryFieldTargetConnected(){
    this.checkValidation();
  }

  openConfirmModal(event) {
    event.preventDefault()
    const modal = document.getElementById('confirmModal')
    modal.classList.add('fr-modal--opened')
  }

  closeConfirmModal() {
    const modal = document.getElementById('confirmModal')
    modal.classList.remove('fr-modal--opened')
    modal.removeAttribute('aria-modal')
  }

  submitForm() {
    const form = document.getElementById('new_internship_application')
    form.submit()
  }
}