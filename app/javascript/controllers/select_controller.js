import { Controller } from "@hotwired/stimulus"
import { get } from "@rails/request.js"
import flatpickr from "flatpickr"

// Connects to data-controller="select"
export default class extends Controller {

  static targets = ["memberID","residencyInput","coverageHistory","coveragePremium","statusInput","termInput","gpInput","coverageMember","cvgEdate","coverageCenter","coverageBatch"]
  timeoutId = 0
  connect() {
    console.log("connected", this.element)
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
    const debounceTimeout = 300 // 1 second debounce timeout
    const handleShowBenefits = () => {
      let loansInput = event.target.value
      let cv_terms = this.termInputTarget.selectedOptions[0].value
      let cv_gperiod = this.gpInputTarget.value
      
        // alert('Timeout executed!'+loansInput)
        if( cv_terms == "" || cv_gperiod == "" )
        {
          alert("Required fields")
          event.target.value = ""
          //mbutton.disabled = true
        }
        else
        {
          this.show_pbenefits(cv_terms,cv_gperiod,loansInput) // show premium details
          //mbutton.disabled = false
        }
    }
    if (this.timeoutId)
    {
      clearTimeout(this.timeoutId)
    }
    this.timeoutId = setTimeout(handleShowBenefits, debounceTimeout)
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
                <option value="">Select a Center</option>
                ${Object.keys(branchOptions).map((id) => `<option value="${id}">${branchOptions[id]}</option>`).join('')}
              </select>
              <input type="text" id="center-input" placeholder="Enter Title">
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
            showCancelButton: true,
            didClose: () => {
              $('#shareRecipeModal').modal('show');
            }
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

  add_coverage()
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
        
          const batches = await response.json();
  
          const batchesOptions = batches.reduce((acc, bt) => {
            acc[bt.id] = bt.name;
            return acc;
          }, {});
  
          const html = `
              <select id="batch-select" class="swal2-input">
                <option value="">Select a Batch</option>
                ${Object.keys(batchesOptions).map((id) => `<option value="${id}">${batchesOptions[id]}</option>`).join('')}
              </select>
              <input type="text" id="title-input" placeholder="Enter Title" class="swal2-input">
              <input type="text" id="description-input" placeholder="Enter Description" class="swal2-input">
            `;
  
          const { value: formValues } = await Swal.fire({
            title: "Add Batch",
            html: html,
            focusConfirm: true,
            preConfirm: async () => {
              const batch = document.getElementById("batch-select").value;
              const title = document.getElementById("title-input").value;
              const desc = document.getElementById("description-input").value;
              if (batch == "" || title == "" || desc == "")
              {
                Swal.showValidationMessage("All fields required!");
              }
              else
              {
                try {
                  const response = await fetch(`/batches/${cmmbrId}/find_batch/?btitle=${title}&bdesc=${desc}`);
                  const data = await response.json();
                  let barrlen = data.length
                  if(batch != "" && barrlen > 0 && title == data[0].title && desc == data[0].description)
                  {
                    Swal.showValidationMessage("Record exist!");
                  }
                  else
                  {
                    return [batch, title, desc];
                  }
                } 
                catch (error) {
                  Swal.showValidationMessage(error.message);
                  throw error;
                }
              }
            },
            showCancelButton: true,
            didClose: () => {
              $('#shareRecipeModal').modal('show');
            }
          });
          
          if (formValues)
          {
            const [nbatch, ntitle, ndesc] = formValues;
            console.log(formValues.length)
            this.batch_turbo("/batches",nbatch,ntitle,ndesc);
            Swal.fire(`Data recorded! ${ntitle} and ${ndesc}`);
            $('#shareRecipeModal').modal('show');
          }
          
        })()
      }
  }

  batch_turbo(urlID,bId,btitle,bdesc)
  {
    let btarget = this.coverageBatchTarget.id
    // console.log(cvgcntr)
    get(`${urlID}/${bId}/add_new_batch?Id=${bId}&title=${btitle}&desc=${bdesc}&target=${btarget}`, {
      responseKind: "turbo-stream"
    })
  }


}
