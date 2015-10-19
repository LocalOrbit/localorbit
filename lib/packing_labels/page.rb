module PackingLabels
  class Page
    class << self
      def make_pages(labels, product_labels_only)
        if product_labels_only == "true"
          labels.each_slice(6).map do |(a,b,c,d,e,f)|
            {
                a: a,
                b: b,
                c: c,
                d: d,
                e: e,
                f: f
            }
            end
        else
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
end

