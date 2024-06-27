import $ from 'jquery';
import { Controller } from 'stimulus';

export default class extends Controller {
  static targets = [
    'emailField',
    'messageField',
    'nameField',
    'submitButton'
  ];
  submitForm(event) {
    event.preventDefault();
    const name = this.nameFieldTarget.value;
    const email = this.emailFieldTarget.value;
    const message = this.messageFieldTarget.value;
    const recipient = "contact@stagedeseconde.education.gouv.fr"
    window.open(
      `mailto:${recipient}?Reply-To=${email}&Sender=${email}&subject=Contact&body=${message}%20-%20Message%20de%20${name}`
    )
  }

  connect() {
  }
}
