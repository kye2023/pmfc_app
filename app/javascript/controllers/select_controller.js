import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"
import flatpickr from "flatpickr"

// Connects to data-controller="select"
export default class extends Controller {
  
  static targets = ["memberID","residencyInput","coverageHistory","coveragePremium","statusInput","termInput","gpInput","coverageMember","cvgEdate","coverageCenter"]
  
  connect() {
    //console.log("connected", this.element);
    //this.outputAgeTarget.hidden = true
    $(".ddate_pick").flatpickr();
    $(".cdate_pick").flatpickr();
  }

  relation_select(event)
  {
    let relationInput = event.target.value
    let memberIdTarget = this.memberIDTarget.value
    // let lnameTarget = this.lnameInputTarget.value
    let urlValue = this.data.get("url")

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

  member_select(event)
  {
    let member_input_selected = event.target.value
    let member_url_value = this.data.get("url")
    let mresidency = this.residencyInputTarget
    let target_history = this.coverageHistoryTarget.id //target turbo params
    let mstatus = this.statusInputTarget
    
    // console.log(member_input_selected+", "+member_url_value);

    fetch(`${member_url_value}/${member_input_selected}/check_residency/?Id=${member_input_selected}`)
      .then(response => response.json())
      .then(data => {

        const mbutton = document.querySelector('.memberBtn');
        console.log("MemberID-"+data.mmbrID+", Coverages : "+data.count_id+" | Residency : "+data.residency+" | "+data.coverage+" day(s) "+"Status :"+data.status);
        
        if( data.coverage > 0 )
        {
          Swal.fire({
            icon: 'error',
            html: `
            Member has 
            <a href="${data.redirecto}" target="_blank">active</a> 
            coverage
          `,
          })
          mbutton.disabled = true
        }
        else
        {
          mbutton.disabled = false
          mresidency.value = data.residency
          // mresidency.disabled = true
          if( data.status == "" || data.status == 0 )
          {
            mstatus.value = "N"
            this.show_coverage_history(member_url_value,member_input_selected,target_history)
          }
          else
          {
            let ret_status = data.status
            ret_status.substr(0,1)
            if(ret_status == "N")
            {
              mstatus.value = "R"
              this.show_coverage_history(member_url_value,member_input_selected,target_history)
            }
            else
            {
              mstatus.value = "R" 
              this.show_coverage_history(member_url_value,member_input_selected,target_history)
            }
            console.log(mstatus+", "+member_url_value+", "+member_input_selected+", "+target_history)
          }
        }

      }).catch(error => console.error(error));
  }

  show_benefits(event)
  {
    let loansInput = event.target.value
    let cv_terms = this.termInputTarget.selectedOptions[0].value
    let cv_gperiod = this.gpInputTarget.value
    if( cv_terms == "" || cv_gperiod == "" )
    {
      alert("Required fields");
      event.target.value = ""
      //mbutton.disabled = true
    }
    else
    {
      this.show_pbenefits(cv_terms,cv_gperiod,loansInput) // show premium details
      //mbutton.disabled = false
    }
    
  }

  show_coverage_history(url_id,id,target)
  {
    console.log(url_id+", "+id+", "+target);
    get(`${url_id}/${id}/coverage_history?Id=${id}&target=${target}`, {
      responseKind: "turbo-stream"
    })
  }

  show_pbenefits(term,gp,loans)
  {
    let cvgUrlId = this.data.get("url")
    let cvgMemberId = this.coverageMemberTarget.selectedOptions[0].value
    let ptarget = this.coveragePremiumTarget.id
    let efDate = this.cvgEdateTarget.value
    let rsdncy = this.residencyInputTarget.value

    // console.log(cvgUrlId+"/"+cvgMemberId+"/"+efDate+term+", "+gp+", "+loans+" - "+ptarget);
    get(`${cvgUrlId}/${cvgMemberId}/coverage_premium_benefits?Id=${cvgMemberId}&efdate=${efDate}&term=${term}&residency=${rsdncy}&gperiod=${gp}&loans=${loans}&ptarget=${ptarget}`, {
      responseKind: "turbo-stream"
    })
  }

  add_center()
  {
    // let btn_center = event.target.value
    let cmmbrId = this.coverageMemberTarget.selectedOptions[0].value
    
      if(cmmbrId == "" )
      {
        Swal.fire({
          icon: "error",
          title: "Oops...",
          text: "Member can't be blank and Member must exist!"
        });
      }
      else
      {
        (async () => {
          $('#shareRecipeModal').modal('hide');
          
          const response = await fetch(`/branches/${cmmbrId}/load_branch`, {
            method: 'GET',
            headers: {
              'Content-Type': 'application/json'
            }
          });
        
          const branches = await response.json();
  
          const branchOptions = branches.reduce((acc, br) => {
            acc[br.id] = br.name;
            return acc;
          }, {});
  
          const html = `
              <select id="branch-select">
                <option value="">Select a branch</option>
                ${Object.keys(branchOptions).map((id) => `<option value="${id}">${branchOptions[id]}</option>`).join('')}
              </select>
              <input type="text" id="center-input" placeholder="Enter quantity">
            `;
  
          const { value: formValues } = await Swal.fire({
            title: "Add Center",
            html: html,
            focusConfirm: true,
            preConfirm: async () => {
              const branch = document.getElementById("branch-select").value;
              const center = document.getElementById("center-input").value;
              if (branch == "" || center == "")
              {
                Swal.showValidationMessage("All fields required!");
              }
              else
              {
                try {
                  const response = await fetch(`/center_names/${cmmbrId}/find_center/?cname=${center}`);
                  const data = await response.json();
                  let carrlen = data.length
                  if(branch != "" && carrlen > 0 && center == data[0].description)
                  {
                    Swal.showValidationMessage("Record exist!");
                  }
                  else
                  {
                    return [branch, center];
                  }
                } 
                catch (error) {
                  Swal.showValidationMessage(error.message);
                  throw error;
                }
              }
            },
            showCancelButton: true
          });
          
          if (formValues)
          {
            
            const [nbranch, ncenter] = formValues;
            console.log(formValues.length)
            this.center_turbo("/center_names",cmmbrId,nbranch,ncenter);
            Swal.fire(`Data recorded! ${nbranch} and ${ncenter}`);
            $('#shareRecipeModal').modal('show');
          }
        })()
      }
    
  }

  center_turbo(urlID,mmbrID,br,cntr)
  {
    let cvgcntr = this.coverageCenterTarget.id
    // console.log(cvgcntr)
    get(`${urlID}/${mmbrID}/add_new_center?cbranch=${br}&cname=${cntr}&target=${cvgcntr}`, {
      responseKind: "turbo-stream"
    })

  }


}

