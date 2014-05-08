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
      if @markets
        @markets.where("#{column} = 't'").any?
      elsif @organization
        @organization.markets.where("#{column} = 't'").any?
      end
    end
  end
end
