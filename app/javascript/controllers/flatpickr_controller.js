import { Controller } from "@hotwired/stimulus"
import Flatpickr from "stimulus-flatpickr"
// Connects to data-controller="flatpickr"
export default class extends Flatpickr {
  connect() {
    super.connect()
    console.log("connected", this.element)
  }
}
