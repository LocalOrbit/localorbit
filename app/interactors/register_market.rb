class RegisterMarket
  include Interactor

  def perform
    context[:market] = Market.create!(market_params)
  end
end
