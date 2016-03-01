module PackingLabels
  class Page
    class << self
      def make_pages(labels, product_label_format)

        if product_label_format == 1
          labels.each_slice(1).map do |(a)|
            {
                a: a
            }
          end
        elsif product_label_format == 4
          labels.each_slice(4).map do |(a,b,c,d)|
            {
                a: a,
                b: b,
                c: c,
                d: d
            }
          end
        elsif product_label_format == 10
          labels.each_slice(10).map do |(a,b,c,d,e,f,g,h,i,j)|
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
                j: j
            }
          end
        else
          labels.each_slice(16).map do |(a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p)|
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
                o: o,
                p: p
            }
          end
        end
      end
    end
  end
end

