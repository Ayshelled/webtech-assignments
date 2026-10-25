import { Controller } from "@hotwired/stimulus"

// Submits its form as soon as a field changes (the "Acting as" select in the navbar)
export default class extends Controller {
  submit() {
    this.element.requestSubmit()
  }
}
