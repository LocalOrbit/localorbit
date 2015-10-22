module PackingLabels
  class Page
    class << self
      def make_pages(labels, product_labels_only)
        if product_labels_only == "true"
          labels.each_slice(15).map do |(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o)|
            {
                a: a,
                b: b,
                c: c,
                d: d,
                e: e,
                f: f,
                g: g,
                h: h,
                i: i,
                j: j,
                k: k,
                l: l,
                m: m,
                n: n,
                o: o
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

