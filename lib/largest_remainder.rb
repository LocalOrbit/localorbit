module LargestRemainder
  module Schema
    Cents = Integer

    ItemId = Object

    Args = RSchema.schema {{
      to_distribute: Cents,
      total:         Cents,
      items:         hash_of(ItemId => Cents)
    }}

    ItemShares = RSchema.schema { hash_of(ItemId => Cents) }
  end

  class << self

    #
    # Fee distribution to order items is accomplished using the largest remainder method
    # calculating the Quota using the Hare (or simple) method.
    # - http://en.wikipedia.org/wiki/Largest_remainder_method
    #
    def distribute_shares(args)
      SchemaValidation.validate!(LargestRemainder::Schema::Args, args)
      to_distribute = args[:to_distribute]
      total = args[:total]
      items = args[:items]

      # Short circuit if there're no items to share with
      return {} if items.empty?

      # Give all shares to the sole item if there's but one
      return { items.first[0] => to_distribute } if items.count == 1

      # All shares are 0 if there's 0 to distribute:
      if to_distribute == 0
        return items.inject({}) do |memo,(id,value)|
          memo[id] = 0
          memo
        end
      end

      # If total is given as 0, set things up to result in even distribution.
      # (Total is n if n items, each item resets to value 1)
      if total == 0
        total = items.count 
        items.each do |id,value|
          items[id] = 1 # discarding 'value' here in favor of even distribution
        end
      end

      # Determine share ratio:
      quota = total.to_r / to_distribute.to_r

      remaining_to_distribute = to_distribute
      items = items.reject do |id,value|
        # items with 0 value are NOT given shares and excluded from output
        value == 0
      end.map do |id,value|
        share, remainder = value.divmod(quota)
        remaining_to_distribute -= share
        { id: id, share: share, remainder: remainder }
      end

      # In order of largest to least remainder, sprinkle on the remainder:
      sorted_items = items.sort_by {|item| item[:remainder]}.reverse
      remaining_to_distribute.times do 
        item = sorted_items.shift
        item[:share] += 1
      end

      # Map the item ids to their respective shares:
      results = items.inject({}) do |memo, item|
        memo[item[:id]] = item[:share]
        memo
      end

      return SchemaValidation.validate!(LargestRemainder::Schema::ItemShares, results)
    end
  end
end
