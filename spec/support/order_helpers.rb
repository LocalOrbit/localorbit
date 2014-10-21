module OrderHelpers
  def verify_each(dom_class, expectations, find_by:)
    items = dom_class.all.to_a
    expectations.each do |exp|
      pref = "#{dom_class.name} with #{find_by} == #{exp[find_by]}"
      item = items.select { |i| i.send(find_by) == exp[find_by] }.first || raise("Couldn't locate #{pref}")
      (exp.keys - [find_by]).each do |key|
        got = item.send(key)
        wanted = exp[key]
        expect(got).to eq(wanted), "#{pref}: wanted #{key} to be #{wanted.inspect} but was #{got.inspect}"
      end
    end
  end
end

RSpec.configure do |config|
  config.include OrderHelpers
end
