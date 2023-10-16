import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"

// Connects to data-controller="select"
export default class extends Controller {
  

  static targets = ["outputAge"]
  connect() {
    
    //console.log("connected", this.element);
    //this.outputAgeTarget.hidden = true

  }

  selected_member(event)
  {
    let member_id = event.target.selectedOptions[0].value
    let target_age = this.outputAgeTarget.id

    console.log(member_id+" "+target_age)
   
    //$('#'+target_age).val(member_id)
    //this.outputAgeTarget.hidden = false

    /**
    get(`/coverages/${member_id}/selected?target=${target_age}`, { 
      responseKind: "turbo-stream" 
    })
    **/

  }


}

