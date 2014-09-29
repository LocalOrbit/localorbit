class ConvertFreshSheetAndNewsletterSubscriptions < ActiveRecord::Migration
  class User < ActiveRecord::Base; end
  class Subscription < ActiveRecord::Base; end
  class SubscriptionType < ActiveRecord::Base; end


  def change
    reversible do |dir|
      dir.up do
        say_with_time "Converting old-style Fresh Sheet and Newsletter flags into subscriptions" do
          ensure_fresh_sheet_and_newsletter_exist

          User.all.each do |user|
            update_user_subscriptions(user)
          end
        end
      end
    end
  end

  private
  def update_user_subscriptions(user)
    begin 
      fresh_sub = Subscription.find_by(user_id: user.id, subscription_type_id: fresh_sheet_type.id)
      if fresh_sub.nil?
        fresh_sub = Subscription.create(user_id: user.id, subscription_type_id: fresh_sheet_type.id, token: new_token)
      end
      if user.send_freshsheet?
        fresh_sub.update_attribute(:deleted_at, nil)
      else
        fresh_sub.update_attribute(:deleted_at, Time.current)
      end
      if fresh_sub.token.nil?
        fresh_sub.update_attribute(:token, new_token)
      end
    rescue Exception => e
      say "!! FAILED to update User #{user.try(:id)} Fresh Sheet subscription: #{e.message}: #{e.backtrace.join("\n")}"
    end

    begin
      news_sub = Subscription.find_by(user_id: user.id, subscription_type_id: newsletter_type.id)
      if news_sub.nil?
        news_sub = Subscription.create(user_id: user.id, subscription_type_id: newsletter_type.id, token: new_token)
      end
      if user.send_newsletter?
        news_sub.update_attribute(:deleted_at, nil)
      else
        news_sub.update_attribute(:deleted_at, Time.current)
      end
      if news_sub.token.nil?
        news_sub.update_attribute(:token, new_token)
      end
    rescue Exception => e
      say "!! FAILED to update User #{user.try(:id)} Newsletter subscription: #{e.message}: #{e.backtrace.join("\n")}"
    end
  end

  def new_token
    SecureRandom.hex(32).upcase
  end

  def ensure_fresh_sheet_and_newsletter_exist
    SubscriptionType.create!(name: "Fresh Sheet", keyword: "fresh_sheet") if fresh_sheet_type.nil?
    SubscriptionType.create!(name: "Newsletter", keyword: "newsletter") if newsletter_type.nil?
  rescue Exception => e
    say "!! FAILED to ensure fresh sheet and newsletter exist: #{e.message}: #{e.backtrace.join("\n")}"
  end

  def fresh_sheet_type
    SubscriptionType.find_by(keyword: "fresh_sheet")
  end

  def newsletter_type
    SubscriptionType.find_by(keyword: "newsletter")
  end
end
