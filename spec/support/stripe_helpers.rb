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
    "statement_descriptor": null,
    "statement_descriptor_suffix": "Farm Link Hawaii",
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

  Templates[:refund] = JSON.parse(%{
     {
      "id": "re_15xlYm2VpjOYk6TmxU8PwVTm",
      "amount": 3800,
      "currency": "usd",
      "created": 1430515236,
      "object": "refund",
      "balance_transaction": "txn_15xlYm2VpjOYk6TmpkgDcvmD",
      "metadata": {
        "lo.order_id": "8876",
        "lo.order_number": "LO-15-HAWAII-0000042"
      },
      "charge": "ch_15xlF22VpjOYk6Tm5fzPN0cr",
      "receipt_number": null,
      "reason": null
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
  # REAL STUFF:
  #

  def create_stripe_token(opts={})
    card_params = {
      number: "4012888888881881",
      exp_month: 5,
      exp_year: 2020,
      cvc: "314"
    }.merge(opts)

    Stripe::Token.create({card: card_params})
  end

  def create_stripe_bank_account_token
    bank_account_params = {
      routing_number: "110000000",
      account_number: "000123456789",
      country: 'US' }
    Stripe::Token.create(bank_account: bank_account_params)
  end

  def create_stripe_credit_card(stripe_customer:,bank_account:)
    tok = create_stripe_token
    stripe_card = stripe_customer.sources.create(source: tok.id)
    bank_account.update stripe_id: stripe_card.id
    stripe_card
  end

  def create_and_attach_stripe_credit_card(organization:,stripe_customer:)
    bank_account = create(:bank_account, :credit_card)
    create_stripe_credit_card(stripe_customer: stripe_customer, bank_account: bank_account)
    organization.bank_accounts << bank_account
    bank_account
  end

  def create_stripe_customer(organization:)
    customer = Stripe::Customer.create(
      description: "[Test] #{organization.name}",
      metadata: {
        "lo.entity_id" => organization.id,
        "lo.entity_type" => 'organization'
      }
    )
    organization.update stripe_customer_id: customer.id
    track_stripe_object_for_cleanup customer
    customer
  end


  def get_or_create_stripe_account_for_market(market)
    # Don't judge me.

    # See if there's already an Account lurking out there in Test land:
    acct = Stripe::Account.all(limit:100).detect { |a| a.email == market.contact_email }
    acct ||= Stripe::Account.create(
      country: 'US',
      email: market.contact_email,
      type: 'standard'
    )

    market.update(stripe_account_id: acct.id)
    acct
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
      rescue StandardError => e
        puts "(Error while trying to delete Stripe object #{obj.inspect}: #{e.message})"
      end
    end
  end
end

RSpec.configure do |config|
  config.include StripeSpecHelpers
end
