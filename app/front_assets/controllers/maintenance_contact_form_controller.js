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
    const recipient = "contact@stagedeseconde.education.gouv.fr"
    event.preventDefault();
    const name = this.nameFieldTarget.value;
    const email = this.emailFieldTarget.value;
    const message = this.messageFieldTarget.value;
    window.open(
      `mailto:${recipient}?Reply-To=${email}&From=${email}&subject=Contact&body=${message}%20-%20Message%20de%20${name}`
    )
  }

  connect() {
  }
}
