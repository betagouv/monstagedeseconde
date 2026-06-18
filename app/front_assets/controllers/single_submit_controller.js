import { Controller } from 'stimulus';

// Disables the submit button as soon as the form is submitted, so a second
// click (or a quick re-submit) doesn't fire a parallel request.
//
// Usage :
//   = form_with ..., data: { controller: "single-submit",
//                            action: "submit->single-submit#lock" }
//
// All submit-type inputs/buttons inside the form are disabled.
export default class extends Controller {
  lock(event) {
    if (this.submitted) {
      event.preventDefault();
      return;
    }
    this.submitted = true;

    const submits = this.element.querySelectorAll(
      'input[type="submit"], button[type="submit"]'
    );
    submits.forEach((el) => {
      el.disabled = true;
      el.setAttribute('aria-busy', 'true');
    });
  }
}
