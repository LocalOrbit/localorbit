class OrganizationDecorator < Draper::Decorator
  include Draper::LazyHelpers
  include MapHelper

  delegate_all

  def locations_map(w=340, h=300)
    addresses = locations.visible.map do |location|
      location.geocode if location
    end.compact

    static_map(addresses, addresses.first, w, h)
  end

  def ship_from_address
    if (address = shipping_location)
      raw "#{address.address}<br/>#{address.city}, #{address.state} #{address.zip}"
    else
      ""
    end
  end

  def delivery_schedules
    all_markets.inject({}) do |result, market|
      result[market] = market.delivery_schedules.visible.order(:day)
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
    bank_accounts.visible.where("account_type not in (?)", %w(savings checking)).count > 0
  end

  def credit_card_options
    bank_accounts.visible.where("account_type not in (?)", %w(savings checking)).map do |card|
      ["#{card.bank_name} ending in #{card.last_four}", card.id]
    end
  end

  def ach_available?
    bank_accounts.visible.where("verified = ? and account_type in (?)", true, %w(savings checking)).count > 0
  end

  def ach_options
    bank_accounts.visible.where("verified = ? and account_type in (?)", true, %w(savings checking)).map do |bank_account|
      ["ACH: #{bank_account.bank_name} - *********#{bank_account.last_four}", bank_account.id]
    end
  end

  def toggle_active_button
    return unless current_user.admin? || current_user.can_manage_market?(current_market)
    title = organization.active? ? "Deactivate" : "Activate"
    status = organization.active? ? "alert" : "notice"
    link_to(
      title,
      update_active_admin_organization_path(organization, organization: {active: !active?}),
      method: :patch,
      class: "btn btn--small #{status}"
    )
  end
end
