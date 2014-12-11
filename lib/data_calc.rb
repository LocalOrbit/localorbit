class DataCalc
  class << self
    def sum_of_field(objects, field, default: nil)
      raise "objects must be a collection supporting #empty? and #inject" unless objects
      if objects.empty?
        return default if default
        raise "If objects is empty, :default MUST be provided."
      end
      objects.inject(0) { |sum, obj| sum + obj.send(field) }
    end

    def sum_of_key(hashes, key, default: nil)
      raise "hashes must be a collection supporting #empty? and #inject" unless hashes
      if hashes.empty?
        return default if default
        raise "If hashes empty, :default MUST be provided."
      end
      hashes.inject(0) { |sum,h| sum + h[key] }
    end

    def sums_of_keys(hashes, keys: nil, default: nil) 
      raise "hashes must be a collection supporting #empty? and #inject" unless hashes
      if hashes.empty?
        return default if default
        raise "If hashes is empty, :default MUST be provided."
      end

      keys ||= hashes.first.keys
      base_hash = default || Hash.new { |h,k| h[k] = 0 }
      return hashes.inject(base_hash) { |sums,h| 
        keys.each { |k|
          sums[k] += h[k]
        }
        sums
      }
    end

  end
end
