class Newsletter < ActiveRecord::Base
  belongs_to :market

  validates :subject, :header, :body, presence: true

  dragonfly_accessor :image

  def recipients
    recipients = Set.new

    if buyers?
      recipients += User.joins(:organizations).where(
        organizations: {id: market.organizations.buying.pluck(:id)},
        users: {send_newsletter: true}
      ).pluck(:name, :email)
    end

    if sellers?
      recipients += User.joins(:organizations).where(
        organizations: {id: market.organizations.selling.pluck(:id)},
        users: {send_newsletter: true}
      ).pluck(:name, :email)
    end

    if market_managers?
      recipients += market.managers.where(send_newsletter: true).pluck(:name, :email)
    end

    recipients
  end
end
