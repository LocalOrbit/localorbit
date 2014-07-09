module Role
  module MarketManager
    extend ActiveSupport::Concern

    def admin?
      false
    end
  end
end
