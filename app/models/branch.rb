class Branch < ApplicationRecord
    validates_presence_of :name, :service_fee
    has_many :batches
    has_many :center_names

    SFEE = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]

    def to_s 
        name
    end

    def count_branch_id(bid)
        total_branch = Batch.where(branch_id: bid).count    
    end

    def branch_premium(plan, bid)
        bid
        plppi = 0
        pgroup = 0
        dpgroup = 0

        abatch = Batch.where(branch_id: bid)
        # abatch.map do |pb| pb.id end
        abatch.each do |ab|
            plppi += ab.coverages.sum(:loan_premium)
            pgroup += ab.coverages.sum(:group_premium)
            acoverage = Coverage.where(batch_id: ab.id) 
            acoverage.each do |ac|
                dpgroup += ac.dependent_coverages.sum(:premium)
            end
        end
        # raise "errors"
        
        case plan
        when "lppi"
            return plppi        
        else
            return pgroup+dpgroup
        end

    end

end
