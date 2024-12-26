import { Controller } from "@hotwired/stimulus";
import flatpickr from "flatpickr";

// Connects to data-controller="flatpickr"
export default class extends Controller {

  static targets = ["checkPlan"]

  connect() {
    console.log("connected", this.element)
    //$(".ddate_pick").flatpicker();
    $(".bdate_pick").flatpickr();
    $(".dmdate_pick").flatpickr();
  }

  toggle(event) {
    const isChecked = event.target.checked;
    console.log("Checkbox is checked:", isChecked);
    // You can add more logic here based on the checkbox state
  }

}
