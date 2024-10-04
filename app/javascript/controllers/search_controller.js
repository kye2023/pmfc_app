import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"
import flatpickr from "flatpickr"

// Connects to data-controller="search"
export default class extends Controller {

  static targets = ["memberID"]

  connect() 
  {
    console.log("connected", this.element);
    $(".ddate_pick").flatpickr();
    $(".cdate_pick").flatpickr();
    // Swal.fire("SweetAlert2 is working!");
  }

  relation_select(event)
  {
    let relationInput = event.target.value
    let memberIdTarget = this.memberIDTarget.value
    // let lnameTarget = this.lnameInputTarget.value
    let urlValue = this.data.get("url")

    console.log(relationInput+" | "+memberIdTarget+" "+urlValue)

    // Date Object "flatpickr"
    let dinputElement = document.querySelector(".ddate_pick")._flatpickr;
    let dateTarget = dinputElement.selectedDates[0];
    // Coversion Date Object to String
    let formattedDate = dateTarget.toLocaleDateString('en-CA'); // "Y-m-d"

    fetch(`${urlValue}/${memberIdTarget}/age_validation/?dbday=${formattedDate}&drelation=${relationInput}`)
    .then(response => response.json())
    .then(data => {
      // console.log(data.validity)
      // alert(data.validity)
      let jbday = new Date(data.bday)
      let formattedDate = jbday.toLocaleDateString('en-US',{ year: 'numeric', month: '2-digit', day: '2-digit' })

      if(data.relation == 'Sibling' && data.validity == false || data.relation == 'Child' && data.validity == false || data.relation == 'Spouse' && data.validity == false || data.relation == 'Parent' && data.validity == false){
        Swal.fire({
          icon: 'error',
          html: `
            <p class="text-center">
              Sibling & Child must be <b>3-21</b> y/o <br>
              Spouse & Parent must be <b>18-65</b> y/o <br><br><br>
              <p class="fs-3">Invalid</p>
              Birthday: ${formattedDate} <br> Age: ${data.age} y/o <br> Relation: ${data.relation}
            </p>
            `,
        })
        event.target.value = ""
        dinputElement.clear()
      }else
      {
        console.log("birth date: "+formattedDate+", Age: "+data.age+", Relation: "+data.relation)
      }
    })
    .catch(error => console.error(error));
  }




}
