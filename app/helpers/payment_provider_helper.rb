module PaymentProviderHelper
	def include_payment_provider_scripts(provider)
		case provider
		when 'balanced'
  		javascript_include_tag 'balanced'
		when 'stripe'
		  javascript_include_tag("https://js.stripe.com/v2/") +
			javascript_include_tag('stripe')
		else
			# AKA 'when nil' (AKA whenever @market is undefined)
		  javascript_include_tag("https://js.stripe.com/v2/") +
			javascript_include_tag('stripe')
  	end
  end
end
