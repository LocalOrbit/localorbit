module Orders
  class Invoicing
    class << self
      def mark_orders_invoiced(orders:)
        results = {
          status: :ok,
          order_results: {}
        }
        orders.each do |order|
          res = mark_order_invoiced(order: order)
          results[:order_results][order.order_number] = res
          if res[:status] == :failed
            results[:status] = :failed
          end
        end

        return SchemaValidation.validate!(MarkingResults, results)
      end

      def mark_order_invoiced(order:)
        order.invoice
        status = order.save ? :ok : :failed
        result = {
          status: status,
          order: order
        }
        return SchemaValidation.validate!(MarkingResult, result)
      end
    end
  end

  #
  # Schema for results structures:
  #
 
  ResultStatus = RSchema::DSL.enum([:ok, :failed])
  OrderNumber = String
  
  MarkingResult = RSchema.schema {{
    status: ResultStatus,
    order: Order
  }}

  MarkingResults = RSchema.schema {{
    status: ResultStatus,
    order_results: hash_of(OrderNumber => MarkingResult)
  }}

end
