class Newsletter < ActiveRecord::Base
  belongs_to :market

  dragonfly_accessor :image
end
