import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "modal" ]

  open() {
    if (this.element.closest(".todos--readonly")) return

    this.modalTarget.showModal()
  }

  close() {
    this.modalTarget.close()
  }
}
