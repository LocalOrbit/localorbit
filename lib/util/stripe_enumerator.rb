module Util
  module StripeEnumerator
    def self.create(params, &fetch) 
      params = params.dup

      Enumerator.new do |y|
        puts ">> (fetching with #{params.inspect})"
        result = fetch.call(params)
        while result
          result.data.each do |item|
            y << item
          end

          if result.has_more
            params.merge!(starting_after: result.data.last.id)
            puts ">> (fetching with #{params.inspect})"
            result = fetch.call(params)
          else
            puts ">> (no has_more, done requesting)"
            result = nil
          end
        end
        puts ">> (exiting while loop)"
      end

    end
  end
end

# e = Util::StripeEnumerator.request(limit: 5) do |params| Stripe::Customer.all(params) end
# i = e.each
# i.next
# i.next
# i.next
