class Branch < ApplicationRecord
    validates_presence_of :name
    has_many :batches
    has_many :center_names
    def to_s 
        name
    end

    def count_branch_id(bid)
        total_branch = Batch.where(branch_id: bid).count    
    end

    def branch_premium(plan)
        plppi =0
        pgroup=0

        batches.each do |b|
            plppi = b.coverages.sum(:loan_premium)
            pgroup= b.coverages.sum(:group_premium)+(b.batch_coverage)
        end
        
        case plan
        when "lppi"
            return plppi        
        else
            return pgroup
        end

    end

end
