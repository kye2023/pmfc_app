class PagesController < ApplicationController
  before_action :authenticate_user!
  def index
    @coverages = Coverage.get_coverages_index(current_user.admin, params[:query], current_user)
    if params[:query].present? == true
      @cntcvg = Coverage.get_coverages_index(current_user.admin, params[:query]=nil, current_user)
    else
      @cntcvg = @coverages
    end

    @cn_exp_cvg = 0
    @cn_act_cvg = 0
    
    @cntcvg.each do |ccvg|
      
      chk_cvg = Coverage.where(member_id: ccvg.member_id)
      ret_cvg = chk_cvg.order(:effectivity,:expiry).last
      cov_aging = ret_cvg.coverage_aging

      cn_aging = cov_aging
      if cn_aging <= 0
        @cn_exp_cvg += 1
      elsif
        @cn_act_cvg += 1  
      end
    end

    @cntmember = Member.count(:id)

  end
  
  def home

  end

  def about

  end

end
