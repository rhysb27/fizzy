import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { name: String }

  dispatch() {
    document.dispatchEvent(new CustomEvent(this.nameValue, { bubbles: true }))
  }
}
