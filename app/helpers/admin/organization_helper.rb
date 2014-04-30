module Admin
  module OrganizationHelper
    def seller_status_options
      [
        ["Select a selling status",nil],
        ["Can Sell", true],
        ["Can Not Sell", false]
      ]
    end
  end
end
