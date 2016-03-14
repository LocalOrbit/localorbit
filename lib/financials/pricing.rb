module Financials
	module Pricing
		include PaymentProvider

		extend self
		def seller_net_percents_by_market(markets)
			result = markets.inject({}) do |res,market|
		    res[market.id.to_s] = market.seller_net_percent
	      res
	    end
	    if markets.length > 0 # result should be {} or populated {}
		    result["all"] = markets.first.seller_net_percent
		    markets.each do |mkt|
		    	if mkt.seller_net_percent < result["all"]
		    		result["all"] = mkt.seller_net_percent
		    	end
		    	result
		    end
		  else
		  	result["all"] = 1
		  end
	    result
		end

		def seller_cc_rate(market)
			cc_rate = BigDecimal(PaymentProvider.approximate_credit_card_rate(market.payment_provider))
			if market.credit_card_payment_fee_payer == 'seller' and market.allow_credit_cards?
				cc_rate
			else
			0
			end
		end
	end
end