module Admin::Financials
  class AutomateMarketPaymentsController < AdminController
    before_action :require_admin

    def index
      @as_of_time = Time.current
      @market_sections = ::Financials::MarketPayments::Faker.mk_market_sections #XXX
      # @seller_sections = ::Financials::SellerPayments::Finder.find_seller_payment_sections(as_of: @as_of_time)
    end

    def create
      market_id = params[:market_id].to_i
      market_sections = ::Financials::MarketPayments::Faker.mk_market_sections #XXX
      ms = market_sections.detect { |m| m[:market_id] == market_id }
      redirect_to({action: :index}, {alert: "TODO: pay #{ms[:market_name]}!"})
    end
  end


end
