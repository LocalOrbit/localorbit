module Admin
  module OrganizationHelper
    def seller_status_options
      [
        ["Select a selling status",nil],
        ["Can Sell", 1],
        ["Can Not Sell", 0]
      ]
    end

    def allow_payment_type?(column)
      column = column.to_sym
      if @markets
        @markets.where(column => true).any?
      elsif @organization
        @organization.markets.where(column => true).any?
      else
        false
      end
    end
  end
end
