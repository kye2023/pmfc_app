import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="birth-date"
export default class extends Controller {

  connect() {
     console.log("connected", this.element);
  }

  /**dependent_validation(event){
    const bdayValue = event.target.value
    console.log(bdayValue);
  }**/

}
