import { Controller } from "@hotwired/stimulus";
import flatpickr from "flatpickr";

// Connects to data-controller="flatpickr"
export default class extends Controller {
  connect() {
    console.log("connected", this.element)

    //$(".ddate_pick").flatpicker();
    $(".bdate_pick").flatpickr();
    $(".dmdate_pick").flatpickr();
  }
}
