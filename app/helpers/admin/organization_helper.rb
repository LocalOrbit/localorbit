module Admin
  module OrganizationHelper
    def seller_status_options
      [
        ["Select a selling status",nil],
        ["Can Sell", 1],
        ["Can Not Sell", 0]
      ]
    end
  end
end
