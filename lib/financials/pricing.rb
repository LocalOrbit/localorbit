module Financials
	module Pricing
		extend self
		def seller_net_percents_by_market(markets)
			result = markets.inject({}) do |res,market|
	      res[market.id.to_s] = market.seller_net_percent
	      res
	    end
	    if markets.length > 0
	    	result["all"] = markets.first.seller_net_percent
		    markets.each do |mkt|
		    	if mkt.seller_net_percent < result["all"]
		    		result["all"] = mkt.seller_net_percent
		    	end
		    	result
		    end
		  else
	    	result["all"] = 1.0
	    result
	  	end
		end
	end
end