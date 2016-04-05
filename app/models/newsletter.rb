class Newsletter < ActiveRecord::Base
  audited allow_mass_assignment: true, associated_with: :market
  belongs_to :market

  validates :header, :body, presence: true
  validates :subject, presence: true, length: {maximum: 50}

  dragonfly_accessor :image
  validates_property :format, of: :image,  in: %w(jpeg png gif)

  def recipients
    newsletter_type = SubscriptionType::Keywords::Newsletter
    subscribers = User.in_market(market).subscribed_to(newsletter_type).includes(:subscriptions)

    recipients = Set.new
    if buyers?
      recipients += subscribers.buyers
    end

    if sellers?
      recipients += subscribers.sellers
    end

    if market_managers?
      recipients += market.managers.subscribed_to(newsletter_type).includes(:subscriptions)
    end

    recipients
  end
end
