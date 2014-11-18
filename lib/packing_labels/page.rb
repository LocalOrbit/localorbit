module PackingLabels
  class Page
    class << self
      def make_pages(labels)
        labels.each_slice(4).map do |(a,b,c,d)|
          {
            a: a,
            b: b,
            c: c,
            d: d
          }
        end
      end
    end
  end
end

