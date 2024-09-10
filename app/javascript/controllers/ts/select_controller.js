import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"


// Connects to data-controller="ts--select"
export default class extends Controller {
  static targets = ["loansInput"];

  connect() {
    //console.log("connected", this.element);
    new TomSelect(this.element)
  }

}
