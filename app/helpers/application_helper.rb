module ApplicationHelper
  include Pagy::Frontend

Pagy::DEFAULT[:items] = 5
Pagy::DEFAULT[:size]  = [1,4,4,1] 
end
