module Admin
  module OrganizationHelper
    def seller_status_options
      [
        ["Any", nil],
        ["Buyer", 0],
        ["Seller", 1]

      ]
    end

    def allow_payment_type?(column)
      column = column.to_sym
      if @markets
        @markets.where(column => true).any?
      elsif @organization
        @organization.markets.where(column => true).any?
      end
    end

    def payment_type_enabled?(column)
      if @organization
        @organization[column.to_sym]
      elsif @markets
        @markets.where("default_#{column}".to_sym => true).any?
      end
    end
  end
end
