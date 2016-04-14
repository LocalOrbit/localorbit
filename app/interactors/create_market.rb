class CreateMarket
  include Interactor

  def perform
    defaults = {
      payment_provider: PaymentProvider.for_new_markets.id,
      stripe_standalone: ENV["USE_STRIPE_STANDALONE_ACCOUNTS"]
    }
    merged_market_data = market_params.nil? ? defaults : defaults.merge(market_params)
    market = Market.create(merged_market_data)
    context[:market] = market

    unless market.valid? && market.errors.empty?
      context.fail!(error: "Could not create Market")
    end
  end

  def rollback
    if context_market = context[:market]
        context_market.destroy
    end
  end

# post data  
# {
    # "utf8"=>"✓", 
    # "authenticity_token"=>"S/X6xzq2q9UpL9OHvH9kopt8Uv5HMyUjeEAgECi2mEY=", 
    # "market"=>{
    #     "name"=>"Daves Market", 
    #     "subdomain"=>"davesmarket", 
    #     "tagline"=>"The world's best tagline", 
    #     "timezone"=>"Eastern Time (US & Canada)", 
    #     "contact_name"=>"Dave Crosby", 
    #     "contact_email"=>"c+market@atomicobject.com", 
    #     "contact_phone"=>"616 821 9214", 
    #     "facebook"=>"davesmarket", 
    #     "twitter"=>"davesmarket", 
    #     "profile"=>"The profile of Daves Market", 
    #     "policies"=>"The policies of Daves Market", 
    #     "closed"=>"0", 
    #     "auto_activate_organizations"=>"1", 
    #     "store_closed_note"=>"We am closed sry.", 
    #     "allow_cross_sell"=>"0", 
    #     "sellers_edit_orders"=>"0", 
    #     "allow_purchase_orders"=>"1", 
    #     "allow_credit_cards"=>"1", 
    #     "allow_ach"=>"1", 
    #     "default_allow_purchase_orders"=>"0", 
    #     "default_allow_credit_cards"=>"1", 
    #     "default_allow_ach"=>"1"}, 
    #     "commit"=>"Add Market"
    # }

    # columns = [
    #   :name,
    #   :subdomain,
    #   :tagline,
    #   :timezone,
    #   :contact_name,
    #   :contact_email,
    #   :contact_phone,
    #   :facebook,
    #   :twitter,
    #   :profile,
    #   :policies,
    #   :logo,
    #   :photo,
    #   :allow_cross_sell,
    #   :auto_activate_organizations,
    #   :closed,
    #   :store_closed_note,
    #   :sellers_edit_orders
    # ]
    # if current_user.admin?
    #   columns.concat([
    #     :active,
    #     :allow_purchase_orders,
    #     :allow_credit_cards,
    #     :allow_ach,
    #     :default_allow_purchase_orders,
    #     :default_allow_credit_cards,
    #     :default_allow_ach,
    #   ])
    # end
    # params.require(:market).permit(columns)
end
