class MarketAddressDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def address_type
    a = []
    if default
      a.push("Default")
    end
    if billing
      a.push("Billing")
    end

    if remit_to
      a.push("Remit-To")
    end
    a.join(', ')
  end
end