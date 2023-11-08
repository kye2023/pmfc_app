module BatchesHelper

  def batch_status(status)
    case status
    when true then content_tag(:span, "Submitted", class: "badge rounded-pill bg-success ")
    else
      content_tag(:span, "Active", class: "badge rounded-pill bg-primary")
    end

  end
end
