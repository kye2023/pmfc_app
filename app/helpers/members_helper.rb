module MembersHelper
  def generate_member_id
    time = Time.new 
    time.strftime("%m-%d%Y%I%M%LM") 
  end

  def status
    "Test"
  end

end
