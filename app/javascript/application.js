// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

//import "./popper"
import "@popperjs/core"
import "bootstrap"
import * as bootstrap from "bootstrap"
import "@rails/request.js"
import Swal from "sweetalert2"

window.Swal = Swal;
Turbo.session.drive = true
window.bootstrap = bootstrap

document.addEventListener("turbo:load", function () {
  // initialize bs toast
  var toastEl = document.querySelector('.toast')
  var toast = new bootstrap.Toast(toastEl)
  toast.show()
});
