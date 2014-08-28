namespace :invoice do
  desc "Generate Invoice PDF for given ORDER"
  task pdf: :environment do
    order_id = ENV["ORDER"]
    order = Order.find(order_id)

    GenerateInvoicePdf.perform(order: order)
  end
end
