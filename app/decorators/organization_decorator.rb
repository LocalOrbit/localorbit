class OrganizationDecorator < Draper::Decorator
  include Draper::LazyHelpers
  include MapHelper

  delegate_all

  def human_org_type
    h.t(org_type, scope: [:decorators, :organization, :org_type])
  end

  def locations_map(w=340, h=300)
    # addresses = locations.visible.map do |location|
    #   location.geocode if location
    # end.compact

    # google_static_map(addresses, addresses.first, w, h, 11)
    ""
  end

  def ship_from_address
    if (address = shipping_location)
      raw "#{address.address}<br/>#{address.city}, #{address.state} #{address.zip}"
    else
      ""
    end
  end

  def ship_from_lat_long
    # address = shipping_location
    # if !address.nil? && !address.geocode.nil?
    #   raw "#{address.geocode.latitude},#{address.geocode.longitude}"
    # else
    #   ""
    # end
    ""
  end

  def delivery_schedules
    all_markets.inject({}) do |result, market|
      result[market] = market.delivery_schedules.delivery_visible.order(:day)
      result
    end
  end

  def shipping_address
    shipping_location.address if shipping_location
  end

  def shipping_city_state_zip
    if shipping_location
      "#{shipping_location.city}, #{shipping_location.state} #{shipping_location.zip}"
    end
  end

  def shipping_phone
    shipping_location.phone if shipping_location
  end

  def credit_cards_available?
    credit_card_options.any?
  end

  def credit_card_options
    @credit_card_options ||= PaymentProvider.select_usable_bank_accounts(primary_payment_provider, bank_accounts.credit_cards.chrono).map do |card|
      [card.display_name, card.id]
    end
  end

  def ach_available?
    ach_options.any?
  end

  def ach_options
    @ach_options ||= bank_accounts.debitable_bank_accounts.map do |bank_account|
      [bank_account.display_name, bank_account.id]
    end
  end

  def affiliation_item(user)
    market_list = organization.markets.pluck(:name).to_sentence
    type = organization.can_sell? ? "Supplier" : "Buyer"
    suspended_tag = user.enabled_for_organization?(self) ? "" : content_tag(:span, "Suspended", class: "suspended-indicator")

    content_tag(:li) do
      content_tag(:span, "#{market_list}: #{name}, #{type}") + suspended_tag
    end
  end

  def can_use_advanced_inventory?
    markets.any? {|m| m.organization.plan.advanced_inventory }
  end

  def can_use_advanced_pricing?
    markets.any? {|m| m.organization.plan.advanced_pricing }
  end

end
