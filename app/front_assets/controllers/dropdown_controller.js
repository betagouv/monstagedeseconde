import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle(event) {
    event.preventDefault()
    const menu = this.menuTarget
    const isShown = menu.style.display === "block"
    menu.style.display = isShown ? "none" : "block"
    this.element.querySelector("button").setAttribute(
      "aria-expanded",
      isShown ? "false" : "true"
    )
  }
}