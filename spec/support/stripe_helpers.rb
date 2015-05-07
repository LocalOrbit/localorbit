module StripeSpecHelpers
  Templates = {}
  Templates[:charge] = JSON.parse(%{
    {
    "id": "ch_15xlYA2VpjOYk6Tm8y5QKhDL",
    "object": "charge",
    "created": 1430515198,
    "livemode": false,
    "paid": true,
    "status": "succeeded",
    "amount": 7600,
    "currency": "usd",
    "refunded": false,
    "source": {
      "id": "card_15xJj92VpjOYk6TmMaDxz2zm",
      "object": "card",
      "last4": "0077",
      "brand": "Visa",
      "funding": "credit",
      "exp_month": 1,
      "exp_year": 2020,
      "country": "US",
      "name": null,
      "address_line1": null,
      "address_line2": null,
      "address_city": null,
      "address_state": null,
      "address_zip": null,
      "address_country": null,
      "cvc_check": null,
      "address_line1_check": null,
      "address_zip_check": null,
      "dynamic_last4": null,
      "metadata": {
      },
      "customer": "cus_69cwOMiSlca8Ky"
    },
    "captured": true,
    "balance_transaction": "txn_15xeeD2VpjOYk6Tm5kwSHR4Q",
    "failure_message": null,
    "failure_code": null,
    "amount_refunded": 0,
    "customer": "cus_69cwOMiSlca8Ky",
    "invoice": null,
    "description": null,
    "dispute": null,
    "metadata": {
    },
    "statement_descriptor": "Farm Link Hawaii",
    "fraud_details": {
    },
    "transfer": "tr_15xlYA2VpjOYk6TmpYnQeiwt",
    "receipt_email": null,
    "receipt_number": null,
    "shipping": null,
    "destination": "acct_15xJY9HouQbaP1MV",
    "application_fee": null,
    "refunds": {
      "object": "list",
      "total_count": 0,
      "has_more": false,
      "url": "/v1/charges/ch_15xlYA2VpjOYk6Tm8y5QKhDL/refunds",
      "data": [

      ]
    }
  }
  }) # end Charge
  
  Templates[:application_fee] = JSON.parse(%{
    {
      "id": "fee_6C3CvCyYu1aT71",
      "object": "application_fee",
      "created": 1430967047,
      "livemode": false,
      "amount": 320,
      "currency": "usd",
      "refunded": false,
      "amount_refunded": 0,
      "refunds": {
        "object": "list",
        "total_count": 0,
        "has_more": false,
        "url": "/v1/application_fees/fee_6C3CvCyYu1aT71/refunds",
        "data": [

        ]
      },
      "balance_transaction": "txn_15zZj02VpjOYk6TmxMoaZH85",
      "account": "acct_15zXYjJo1Ucry63F",
      "application": "ca_5vj31wLn9y0tO1AOBXSs20NcwKHAcPO0",
      "charge": "py_15zf63Jo1Ucry63FAm2OuJHM",
      "originating_transaction": "ch_15zf622VpjOYk6Tm8ptYKMoT"
    }
  })

  class Wrapper
    def initialize(params)
      @params = params || "Can't make a Wrapper with nil params!"
    end
    def method_missing(mname)
      key = mname.to_s
      if @params.keys.include?(key)
        val = @params[key]
        if Hash === val
          return Wrapper.new(val)
        else
          return val
        end
      end
    end

    def [](key)
      @params[key.to_s]
    end
    
    def keys
      @params.keys.map { |k| k.to_sym }
    end

    def try(mname)
      method_missing(mname)
    end
  end

  def create_stripe_mock(type, params={})
    # template_data = HashWithIndifferentAccess.new(Templates[type.to_sym])
    template_data = Templates[type.to_sym]
    if template_data
      Wrapper.new(HashWithIndifferentAccess.new(template_data).merge(params))
    else
      raise "Dunno how to create a Stripe test object for #{type.inspect}"
    end
  end

  #
  # For dealing with real Stripe entities:
  #
  def track_stripe_object_for_cleanup(obj)
    @stripe_objects_to_cleanup ||= []
    @stripe_objects_to_cleanup << obj
  end

  def cleanup_stripe_objects
    (@stripe_objects_to_cleanup || []).each do |obj|
      begin
        obj.delete
      rescue Exception => e
        puts "(Error while trying to delete Stripe object #{obj.inspect}: #{e.message})"
      end 
    end
  end
end

RSpec.configure do |config|
  config.include StripeSpecHelpers
end
