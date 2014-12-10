module Admin
  class CleanupPayments
    class << self
      def run
        puts "\n\n\n\n"
        puts "***************************************************************"
        puts
        puts "Connected to LocalOrbit environment '#{Figaro.env.deploy_env}'"
        puts
        puts "***************************************************************"
        puts "Clean up Payments and Order History"
        puts "(Type quit to leave.)"
        alive = true
        while alive
          print "Enter the order number or id> "
          input = gets.strip
          case input
          when /^\s*$/
            # blank, loop
          when /(q|quit|exit)/i
            alive = false
          else
            remove_failed_refunds(input)
          end
        end
        puts "Exiting."
      end

      private

      def remove_failed_refunds(o)
        order =if o.is_a?(Order)
                 o
               else
                 Order.where(id: o).first || Order.find_by_order_number(o)
               end
        if order.nil?
          puts "Couldn't find Order with id or order_number '#{o}'"
          return nil
        end

        pmts = order.payments.buyer_payments.where(payment_type: "order refund", status:"failed")
        if pmts.empty?
          puts "Order #{order.id} has no failed order refunds."
        else
          pmts.each do |pmt|
            remove_payment(pmt)
          end
          nil
        end
      end

      def remove_payment(pmt)
        pmt = pmt.is_a?(Payment) ? pmt : Payment.find(pmt)
        puts ">>> OK TO DELETE PAYMENT ??? <<<"
        puts fmt_pmt(pmt)
        print "Type 'delete'> "
        ans = gets
        if ans =~ /delete/i
          puts "Deleting Payment #{pmt.id}..."
          pmt.audits.each do |audit| 
            puts "  destoying Audit #{audit.id}"
            audit.destroy 
          end
          pmt.destroy
          puts "Payment #{pmt.id} removed."
        end
      end

      def help_failed_refund(balanced_uri)
        payment = Payment.find_by(balanced_uri: balanced_uri)
        order = payment.orders.first

        puts "Order id: #{attstring(order,:id, :order_number,:created_at,:placed_at)}"
        puts "Original payment: #{attstring(payment,:id,:amount,:payment_type,:payment_method,:status,:balanced_uri, :created_at)}"
        print_events(payment)
        puts "All payments for order #{order.order_number}:"
        order.payments.each do |pmt|
          puts "  #{attstring pmt,:id,:amount,:payment_type,:payment_method,:status,:balanced_uri,:created_at}"
        end
        order
      end

      def attstring(obj, *keys)
        str = keys.map do |key| 
          val = obj.send(key)
          "#{key}: #{val}"
        end.join(", ")
        str
      end

      def print_events(payment)
        payment = payment.is_a?(Payment) ? payment : Payment.find(payment)
        if payment and (trans = payment.balanced_transaction)
          events = trans.events.sort_by(&:occurred_at)
          puts "Payment #{payment.id} events:"
          events.each do |e|
            puts "  #{attstring(e, :type, :occurred_at)}"
          end
        else
          puts "No Balanced transaction for Payment #{payment.id}"
        end
        nil
      end


      def print_buyer_payments(order)
        order = order.is_a?(Order) ? order : Order.find(order)
        puts "Payments for Order #{order.id} (#{order.order_number}), total cost: #{order.total_cost}"
        print_payments order.payments.buyer_payments

      end

      def print_payments(payments)
        sum = BigDecimal.new("0.0")
        payments.each do |pmt|
          puts fmt_pmt(pmt)
          sum += pmt.amount
        end
        puts "Total: #{sum}"
      end

      def fmt_pmt(pmt)
        pmt = pmt.is_a?(Payment) ? pmt : Payment.find(pmt)
        "Payment(#{pmt.id}) #{pmt.payment_type} $#{pmt.amount} (ref $#{pmt.refunded_amount}) #{pmt.payment_method}, status: #{pmt.status}, on: #{pmt.created_at.to_date.to_s} #{pmt.balanced_uri}"
      end
    end

    private
  end
end

if __FILE__ == $0
  Admin::CleanupPayments.run
end
