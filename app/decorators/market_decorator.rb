class MarketDecorator < Draper::Decorator
  include ActionView::Helpers::NumberHelper
  include Draper::LazyHelpers
  include MapHelper

  delegate_all

  def affiliation_item(_)
    content_tag(:li, "#{name}, Market Manager")
  end

  def first_address
    addresses.visible.first # remaining, in case (TODO should this go?)
  end

  def default_address
    default_addrs = addresses.visible.select{|addr| addr if addr.default? } # this should have only one in the array if any
    unless default_addrs.empty? 
      default_addrs.first
    else
      addresses.visible.first # if an address can be properly default or billing via those attrs, it must also be visible (not soft-deleted)
    end
  end

  def billing_address
    billing_addrs = addresses.visible.select{|addr| addr if addr.billing? } # should be just one again
    unless billing_addrs.empty?
      billing_addrs.first 
    else
      addresses.visible.first
    end
  end

  def remit_to_address
    remit_to_addrs = addresses.visible.select{|addr| addr if addr.remit_to? } # should be just one again
    unless remit_to_addrs.empty?
      remit_to_addrs.first
    end
  end

  def seller_locations_map(w=400, h=400)
    addresses = organizations.selling.map do |seller|
      seller.shipping_location.geocode if seller.shipping_location
    end.compact

    static_map(addresses, default_address.try(:geocode), w, h)
  end

  def has_address?
    addresses.visible.any?
  end

  def has_remit_to_address?
    remit_to_address
  end

  def remit_to_name
    remit_to_address.name
  end

  def billing_street_address
    billing_address.address
  end

  def remit_to_street_address
    remit_to_address.address
  end

  def billing_city_state_zip
    "#{billing_address.city}, #{billing_address.state} #{billing_address.zip}"
  end

  def remit_to_city_state_zip
    "#{remit_to_address.city}, #{remit_to_address.state} #{remit_to_address.zip}"
  end

  def billing_address_phone_number
    if billing_address.phone
      number = billing_address.phone.to_s
    else
      number = contact_phone.to_s
    end
    formatted_num = number.gsub(/[^0-9]/, "")
    if formatted_num.length == 10
      number_to_phone(formatted_num, area_code: true)
    else
      number.to_s
    end
  end

  def remit_to_phone_number
    if remit_to_address.phone
      number = remit_to_address.phone.to_s
    else
      number = contact_phone.to_s
    end
    formatted_num = number.gsub(/[^0-9]/, "")
    if formatted_num.length == 10
      number_to_phone(formatted_num, area_code: true)
    else
      number.to_s
    end
  end

  # TODO: implement default_street_address etc. if needed.
  # TODO: remove repetion.

  def default_address_phone_number
    # The 'try' here bypasses an erroneous thrown error if there's no default_address
    if default_address.try(:phone)
      number = default_address.phone.to_s
    else
      number = contact_phone.to_s
    end
    formatted_num = number.gsub(/[^0-9]/, "")
    if formatted_num.length == 10
      number_to_phone(formatted_num, area_code: true)
    else
      number.to_s
    end
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
