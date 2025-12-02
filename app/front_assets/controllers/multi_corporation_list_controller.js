import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["list"];

  edit(event) {
    // This is handled by Turbo Frame navigation usually
    // Clicking edit link loads the edit form into the form frame
  }
}


