class MarketDecorator < Draper::Decorator
  include ActionView::Helpers::NumberHelper
  include Draper::LazyHelpers
  include MapHelper

  delegate_all

  def affiliation_item(_)
    content_tag(:li, "#{name}, Market Manager")
  end

  def first_address
    addresses.visible.first # remaining, in case (TODO check if it should go)
  end

  def default_address
    default_addrs = addresses.map{|addr| addr if addr.default == true and addr.visible} # this should have only one in the array if any
    # double check ^ OK? same for billing_address
    unless default_addrs.empty? 
      default_addrs.first
    else
      addresses.visible.first # Check: presumably if an address can be default or billing via those db attrs, it is also visible (not soft-deleted)
    end
  end

  def billing_address
    billing_addrs = addresses.map{|addr| addr if addr.billing == true and addr.visible} # should be just one again
    unless billing_addrs.empty?
      billing_addrs.first 
    else
      addresses.visible.first
    end
  end

  def seller_locations_map(w=400, h=400)
    addresses = organizations.selling.map do |seller|
      seller.shipping_location.geocode if seller.shipping_location
    end.compact

    if (center = first_address.try(:geocode))
      static_map(addresses, center, w, h)
    else
      ""
    end
  end

  def has_address?
    addresses.visible.any?
  end

  def street_address
    first_address.address
  end

  def city_state_zip
    "#{first_address.city}, #{first_address.state} #{first_address.zip} "
  end

  def phone_number
    first_address.phone
  end

  def display_contact_phone
    number = contact_phone.to_s.gsub(/[^0-9]/, "")

    # if we have a clean phone number, format it appropriately, otherwise
    # just display what they give us
    if number.length == 10
      number_to_phone(number, area_code: true)
    else
      contact_phone.to_s
    end
  end

  def display_plan_interval
    if plan_interval == 1
      "Monthly"
    elsif plan_interval == 12
      "Yearly"
    else
      "Not Set"
    end
  end

  def header
    if name.blank?
      changes[:name].first
    else
      name
    end
  end

  def payble_accounts_for_select
    bank_accounts.visible.where(account_type: %w(savings checking)).order(verified: :desc).map do |bank_account|
      [bank_account.display_name, bank_account.id]
    end
  end

  def payment_accounts_for_select
    bank_accounts.visible.map do |bank_account|
      next unless bank_account.usable_for?(:debit)
      [bank_account.display_name, bank_account.id]
    end.compact
  end
end
