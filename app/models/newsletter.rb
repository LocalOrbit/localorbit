class Newsletter < ActiveRecord::Base
  audited allow_mass_assignment: true, associated_with: :market
  belongs_to :market

  validates :subject, :header, :body, presence: true

  dragonfly_accessor :image
  validates_property :format, of: :image,  in: %w(jpeg png gif)

  def recipients
    recipients = Set.new

    if buyers?
      recipients += recipients_for_organizations(market.organizations.buying)
    end

    if sellers?
      recipients += recipients_for_organizations(market.organizations.selling)
    end

    if market_managers?
      recipients += market.managers.where(send_newsletter: true).select(:name, :email)
    end

    recipients
  end

  private

  def recipients_for_organizations(organizations)
    User.joins(:organizations).where(
      organizations: {id: organizations.pluck(:id)},
      users: {send_newsletter: true}
    ).select(:name, :email)
  end
end
