# Small service to make sure customer.loyalty_points are updated after a loyalty_event is created
module Loyalty
  class EventCreatorHelperService

    def self.call(customer, &block)
      customer.with_lock do
        loyalty_event = block.call
        customer.update!(loyalty_points: customer.loyalty_points + loyalty_event.points)
      end
    end

  end
end
