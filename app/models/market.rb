class Market < ActiveRecord::Base
  validates :name, :subdomain, uniqueness: true

  before_save :clean_twitter_slug

  has_many :managed_markets
  has_many :managers, through: :managed_markets, source: :user

  def clean_twitter_slug
    if twitter && twitter.match(/^@/)
      self.twitter = twitter[1..-1]
    end
  end
end
