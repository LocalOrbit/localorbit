class Import
  def self.setup
    Dir[Rails.root.join("lib/import/models/*.rb")].each {|f| require f }
    @@ready = true
  end

  def self.market(id)
    Import.setup unless defined?(@@ready) && @@ready

    ActiveRecord::Base.transaction do
      Legacy::Market.find(id).import
    end
  end

  def self.clear_all
    Organization.destroy_all
    BankAccount.destroy_all
    Cart.destroy_all
    CartItem.destroy_all
    Location.destroy_all
    Delivery.destroy_all
    DeliverySchedule.destroy_all
    Order.destroy_all
    OrderItem.destroy_all
    OrderPayment.destroy_all
    Payment.destroy_all
    ProductDelivery.destroy_all
    UserOrganization.destroy_all
    User.destroy_all(role: "user")
    MarketAddress.destroy_all
    MarketOrganization.destroy_all
    ManagedMarket.destroy_all
    Market.destroy_all
  end
end
