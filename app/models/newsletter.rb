class Newsletter < ActiveRecord::Base
  audited allow_mass_assignment: true, associated_with: :market
  belongs_to :market

  validates :subject, :header, :body, presence: true

  dragonfly_accessor :image
  validates_property :format, of: :image,  in: %w(jpeg png gif)

  def recipients
    newsletter_type = SubscriptionType::Keywords::Newsletter
    subscribers = User.in_market(market).subscribed_to(newsletter_type)

    recipients = Set.new
    if buyers?
      recipients += subscribers.buyers
    end

    if sellers?
      recipients += subscribers.sellers
    end

    if market_managers?
      recipients += market.managers.subscribed_to(newsletter_type)
    end

    recipients
  end
end
