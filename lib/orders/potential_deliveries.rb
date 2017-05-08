module Orders
  class PotentialDeliveries
    class << self

      def get_potential_deliveries(starting_delivery, number)
        i = 0
        new_delivery = starting_delivery
        while i < number do
          new_delivery = new_delivery.delivery_schedule.next_delivery(new_delivery)
          i = i + 1
        end
      end

    end
  end
end