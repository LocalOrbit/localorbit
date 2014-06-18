module Imported
  module Password
    def self.update_password_sent_at_for_markets(markets)
      markets.each do |market|
        User.with_primary_market(market).each do |user|
          user.send_import_password_reset_instructions
        end
      end
    end
  end
end
