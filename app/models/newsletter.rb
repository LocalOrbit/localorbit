class Newsletter < ActiveRecord::Base
  belongs_to :market

  validates :subject, :header, :body, presence: true

  dragonfly_accessor :image
end
