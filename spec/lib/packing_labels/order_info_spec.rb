describe PackingLabels::OrderInfo do
  subject { described_class }

  let(:market) { create(:market) }

  let!(:buyer) { create(:organization, :buyer, name: "Big Money", markets: [market]) }
  let!(:seller) { create(:organization, :seller, name: "Good foodz", markets: [market]) }
  let!(:product1) { create(:product, :sellable, name: "Giant Carrots", organization: seller) }
  let!(:product2) { create(:product, :sellable, name: "Tiny Beets", organization: seller) }
  let!(:delivery_schedule) { create(:delivery_schedule, market: market) }
  let!(:deliver_on) { 2.days.from_now }
  let!(:delivery) { create(:delivery, delivery_schedule: delivery_schedule, deliver_on: deliver_on) }
  let!(:order_items) do
    [
      create(:order_item, product: product1, seller_name: seller.name, name: product1.name, unit_price: 6.50, quantity: 5, quantity_delivered: 0, unit: "stuff"),
      create(:order_item, product: product2, seller_name: seller.name, name: product2.name, unit_price: 4.25, quantity: 3, quantity_delivered: 0, unit: "each"),
    ]
  end

  let(:order_number) { "LO-ADA-0000001" }
  let!(:order) { create(:order, items: order_items, organization: buyer, market: market, delivery: delivery, order_number: order_number, total_cost: order_items.sum(&:gross_total)) }

  let(:host) { "the host" }
  let(:qr_code) { "the QR code" }

  before do
    market.update(logo: dont_panic)
  end

  describe ".make_product_info" do
    context "an OrderItem with Lots" do
      let(:order_item) { order_items.first }
      let(:lot) { order_item.lots.first }

      it "includes a lot description" do
        expect(subject.make_product_info(order_item)).to eq({
          product_name: order_item.name,
          unit_desc: order_item.unit,
          quantity: order_item.quantity,
          lot_desc: "Lot ##{lot.lot_id}",
          producer_name: order_item.seller_name
        })
      end
    end

    context "an OrderItem without Lots" do
      let(:order_item) { order_items.first }
      before { order_item.lots.destroy_all }
      it "has a nil lot description" do
        expect(subject.make_product_info(order_item)).to eq({
          product_name: order_item.name,
          unit_desc: order_item.unit,
          quantity: order_item.quantity,
          lot_desc: nil,
          producer_name: order_item.seller_name
        })
      end
    end
  end

  describe ".make_product_infos" do
    it "converts an Order's items into a list of product_info structures" do
      expect(subject.make_product_infos(order)).to contain_exactly(
        subject.make_product_info(order_items[0]),
        subject.make_product_info(order_items[1])
      )
    end
  end

  def formatted_delivery_time(t)
    t.strftime("%B %e, %Y")
  end

  describe ".make_order_info" do
    let(:expected_product_infos) { subject.make_product_infos(order) }

    context "a normal Order" do

      it "returns an order_info" do
        expect(PackingLabels::QrCode).to receive(:make_qr_code).with(order,host:host).and_return(qr_code)

        order_info = subject.make_order_info(order,host:host)
        expect(order_info).to eq({
          deliver_on: formatted_delivery_time(deliver_on),
          order_number: order_number,
          buyer_name: buyer.name,
          market_logo_url: market.logo.url,
          qr_code_url: qr_code,
          products: expected_product_infos
        })
      end
    end

    context "missing Market logo" do
      before do
        market.update(logo: nil)
      end

      it "includes a nil logo url" do
        expect(PackingLabels::QrCode).to receive(:make_qr_code).with(order,host:host).and_return(qr_code)

        order_info = subject.make_order_info(order,host:host)
        expect(order_info).to eq({
          deliver_on: formatted_delivery_time(deliver_on),
          order_number: order_number,
          buyer_name: buyer.name,
          market_logo_url: nil,
          qr_code_url: qr_code,
          products: expected_product_infos
        })
      end
    end

    context "missing delivery" do
      before do
        order.update(delivery:nil)
      end

      it "raises a specific error" do
        expect { subject.make_order_info(order,host:host) }.to raise_error(/delivery/)
      end
    end
    context "null deliver_on" do
      before do
        order.delivery.update_column(:deliver_on, nil)
      end
      it "raises a specific error" do
        expect { subject.make_order_info(order,host:host) }.to raise_error(/delivery/)
      end
    end
  end

  describe ".make_order_infos" do
    let!(:buyer2) { create(:organization, :buyer, name: "Small Timer", markets: [market]) }
    let!(:product3) { create(:product, :sellable, name: "Flat Chikkens", organization: seller) }
    let!(:order_items2) do
      [
        create(:order_item, product: product3, seller_name: seller.name, name: product3.name, unit_price: 10, quantity: 2, quantity_delivered: 0, unit: "stacks"),
      ]
    end

    let(:order_number2) { "LO-ADA-0000002" }
    let!(:order2) { create(:order, items: order_items2, organization: buyer2, market: market, delivery: delivery, order_number: order_number2, total_cost: order_items2.sum(&:gross_total)) }
    let(:orders) { delivery.orders }

    it "generates a list of order_infos based on a list of Orders" do
      allow(PackingLabels::QrCode).to receive(:make_qr_code).and_return(qr_code)

      order_infos = subject.make_order_infos(orders:orders, host:host)

      expect(order_infos).to contain_exactly(
        subject.make_order_info(order,host:host),
        subject.make_order_info(order2,host:host)
      )
    end
  end

  # A small PNG:
  let(:dont_panic) {
    Base64.decode64("iVBORw0KGgoAAAANSUhEUgAAAB4AAAAZCAIAAACpVwlNAAAKQWlDQ1BJQ0Mg\nUHJvZmlsZQAASA2dlndUU9kWh8+9N73QEiIgJfQaegkg0jtIFQRRiUmAUAKG\nhCZ2RAVGFBEpVmRUwAFHhyJjRRQLg4Ji1wnyEFDGwVFEReXdjGsJ7601896a\n/cdZ39nnt9fZZ+9917oAUPyCBMJ0WAGANKFYFO7rwVwSE8vE9wIYEAEOWAHA\n4WZmBEf4RALU/L09mZmoSMaz9u4ugGS72yy/UCZz1v9/kSI3QyQGAApF1TY8\nfiYX5QKUU7PFGTL/BMr0lSkyhjEyFqEJoqwi48SvbPan5iu7yZiXJuShGlnO\nGbw0noy7UN6aJeGjjAShXJgl4GejfAdlvVRJmgDl9yjT0/icTAAwFJlfzOcm\noWyJMkUUGe6J8gIACJTEObxyDov5OWieAHimZ+SKBIlJYqYR15hp5ejIZvrx\ns1P5YjErlMNN4Yh4TM/0tAyOMBeAr2+WRQElWW2ZaJHtrRzt7VnW5mj5v9nf\nHn5T/T3IevtV8Sbsz55BjJ5Z32zsrC+9FgD2JFqbHbO+lVUAtG0GQOXhrE/v\nIADyBQC03pzzHoZsXpLE4gwnC4vs7GxzAZ9rLivoN/ufgm/Kv4Y595nL7vtW\nO6YXP4EjSRUzZUXlpqemS0TMzAwOl89k/fcQ/+PAOWnNycMsnJ/AF/GF6FVR\n6JQJhIlou4U8gViQLmQKhH/V4X8YNicHGX6daxRodV8AfYU5ULhJB8hvPQBD\nIwMkbj96An3rWxAxCsi+vGitka9zjzJ6/uf6Hwtcim7hTEEiU+b2DI9kciWi\nLBmj34RswQISkAd0oAo0gS4wAixgDRyAM3AD3iAAhIBIEAOWAy5IAmlABLJB\nPtgACkEx2AF2g2pwANSBetAEToI2cAZcBFfADXALDIBHQAqGwUswAd6BaQiC\n8BAVokGqkBakD5lC1hAbWgh5Q0FQOBQDxUOJkBCSQPnQJqgYKoOqoUNQPfQj\ndBq6CF2D+qAH0CA0Bv0BfYQRmALTYQ3YALaA2bA7HAhHwsvgRHgVnAcXwNvh\nSrgWPg63whfhG/AALIVfwpMIQMgIA9FGWAgb8URCkFgkAREha5EipAKpRZqQ\nDqQbuY1IkXHkAwaHoWGYGBbGGeOHWYzhYlZh1mJKMNWYY5hWTBfmNmYQM4H5\ngqVi1bGmWCesP3YJNhGbjS3EVmCPYFuwl7ED2GHsOxwOx8AZ4hxwfrgYXDJu\nNa4Etw/XjLuA68MN4SbxeLwq3hTvgg/Bc/BifCG+Cn8cfx7fjx/GvyeQCVoE\na4IPIZYgJGwkVBAaCOcI/YQRwjRRgahPdCKGEHnEXGIpsY7YQbxJHCZOkxRJ\nhiQXUiQpmbSBVElqIl0mPSa9IZPJOmRHchhZQF5PriSfIF8lD5I/UJQoJhRP\nShxFQtlOOUq5QHlAeUOlUg2obtRYqpi6nVpPvUR9Sn0vR5Mzl/OX48mtk6uR\na5Xrl3slT5TXl3eXXy6fJ18hf0r+pvy4AlHBQMFTgaOwVqFG4bTCPYVJRZqi\nlWKIYppiiWKD4jXFUSW8koGStxJPqUDpsNIlpSEaQtOledK4tE20Otpl2jAd\nRzek+9OT6cX0H+i99AllJWVb5SjlHOUa5bPKUgbCMGD4M1IZpYyTjLuMj/M0\n5rnP48/bNq9pXv+8KZX5Km4qfJUilWaVAZWPqkxVb9UU1Z2qbapP1DBqJmph\natlq+9Uuq43Pp893ns+dXzT/5PyH6rC6iXq4+mr1w+o96pMamhq+GhkaVRqX\nNMY1GZpumsma5ZrnNMe0aFoLtQRa5VrntV4wlZnuzFRmJbOLOaGtru2nLdE+\npN2rPa1jqLNYZ6NOs84TXZIuWzdBt1y3U3dCT0svWC9fr1HvoT5Rn62fpL9H\nv1t/ysDQINpgi0GbwaihiqG/YZ5ho+FjI6qRq9Eqo1qjO8Y4Y7ZxivE+41sm\nsImdSZJJjclNU9jU3lRgus+0zwxr5mgmNKs1u8eisNxZWaxG1qA5wzzIfKN5\nm/krCz2LWIudFt0WXyztLFMt6ywfWSlZBVhttOqw+sPaxJprXWN9x4Zq42Oz\nzqbd5rWtqS3fdr/tfTuaXbDdFrtOu8/2DvYi+yb7MQc9h3iHvQ732HR2KLuE\nfdUR6+jhuM7xjOMHJ3snsdNJp9+dWc4pzg3OowsMF/AX1C0YctFx4bgccpEu\nZC6MX3hwodRV25XjWuv6zE3Xjed2xG3E3dg92f24+ysPSw+RR4vHlKeT5xrP\nC16Il69XkVevt5L3Yu9q76c+Oj6JPo0+E752vqt9L/hh/QL9dvrd89fw5/rX\n+08EOASsCegKpARGBFYHPgsyCRIFdQTDwQHBu4IfL9JfJFzUFgJC/EN2hTwJ\nNQxdFfpzGC4sNKwm7Hm4VXh+eHcELWJFREPEu0iPyNLIR4uNFksWd0bJR8VF\n1UdNRXtFl0VLl1gsWbPkRoxajCCmPRYfGxV7JHZyqffS3UuH4+ziCuPuLjNc\nlrPs2nK15anLz66QX8FZcSoeGx8d3xD/iRPCqeVMrvRfuXflBNeTu4f7kufG\nK+eN8V34ZfyRBJeEsoTRRJfEXYljSa5JFUnjAk9BteB1sl/ygeSplJCUoykz\nqdGpzWmEtPi000IlYYqwK10zPSe9L8M0ozBDuspp1e5VE6JA0ZFMKHNZZruY\njv5M9UiMJJslg1kLs2qy3mdHZZ/KUcwR5vTkmuRuyx3J88n7fjVmNXd1Z752\n/ob8wTXuaw6thdauXNu5Tnddwbrh9b7rj20gbUjZ8MtGy41lG99uit7UUaBR\nsL5gaLPv5sZCuUJR4b0tzlsObMVsFWzt3WazrWrblyJe0fViy+KK4k8l3JLr\n31l9V/ndzPaE7b2l9qX7d+B2CHfc3em681iZYlle2dCu4F2t5czyovK3u1fs\nvlZhW3FgD2mPZI+0MqiyvUqvakfVp+qk6oEaj5rmvep7t+2d2sfb17/fbX/T\nAY0DxQc+HhQcvH/I91BrrUFtxWHc4azDz+ui6rq/Z39ff0TtSPGRz0eFR6XH\nwo911TvU1zeoN5Q2wo2SxrHjccdv/eD1Q3sTq+lQM6O5+AQ4ITnx4sf4H++e\nDDzZeYp9qukn/Z/2ttBailqh1tzWibakNml7THvf6YDTnR3OHS0/m/989Iz2\nmZqzymdLz5HOFZybOZ93fvJCxoXxi4kXhzpXdD66tOTSna6wrt7LgZevXvG5\ncqnbvfv8VZerZ645XTt9nX297Yb9jdYeu56WX+x+aem172296XCz/ZbjrY6+\nBX3n+l37L972un3ljv+dGwOLBvruLr57/17cPel93v3RB6kPXj/Mejj9aP1j\n7OOiJwpPKp6qP6391fjXZqm99Oyg12DPs4hnj4a4Qy//lfmvT8MFz6nPK0a0\nRupHrUfPjPmM3Xqx9MXwy4yX0+OFvyn+tveV0auffnf7vWdiycTwa9HrmT9K\n3qi+OfrW9m3nZOjk03dp76anit6rvj/2gf2h+2P0x5Hp7E/4T5WfjT93fAn8\n8ngmbWbm3/eE8/syOll+AAAACXBIWXMAAAsTAAALEwEAmpwYAAAEImlUWHRY\nTUw6Y29tLmFkb2JlLnhtcAAAAAAAPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9i\nZTpuczptZXRhLyIgeDp4bXB0az0iWE1QIENvcmUgNS40LjAiPgogICA8cmRm\nOlJERiB4bWxuczpyZGY9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkvMDIvMjIt\ncmRmLXN5bnRheC1ucyMiPgogICAgICA8cmRmOkRlc2NyaXB0aW9uIHJkZjph\nYm91dD0iIgogICAgICAgICAgICB4bWxuczp0aWZmPSJodHRwOi8vbnMuYWRv\nYmUuY29tL3RpZmYvMS4wLyIKICAgICAgICAgICAgeG1sbnM6ZXhpZj0iaHR0\ncDovL25zLmFkb2JlLmNvbS9leGlmLzEuMC8iCiAgICAgICAgICAgIHhtbG5z\nOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyIKICAgICAg\nICAgICAgeG1sbnM6eG1wPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAv\nIj4KICAgICAgICAgPHRpZmY6UmVzb2x1dGlvblVuaXQ+MjwvdGlmZjpSZXNv\nbHV0aW9uVW5pdD4KICAgICAgICAgPHRpZmY6Q29tcHJlc3Npb24+NTwvdGlm\nZjpDb21wcmVzc2lvbj4KICAgICAgICAgPHRpZmY6WFJlc29sdXRpb24+NzI8\nL3RpZmY6WFJlc29sdXRpb24+CiAgICAgICAgIDx0aWZmOk9yaWVudGF0aW9u\nPjE8L3RpZmY6T3JpZW50YXRpb24+CiAgICAgICAgIDx0aWZmOllSZXNvbHV0\naW9uPjcyPC90aWZmOllSZXNvbHV0aW9uPgogICAgICAgICA8ZXhpZjpQaXhl\nbFhEaW1lbnNpb24+MzA8L2V4aWY6UGl4ZWxYRGltZW5zaW9uPgogICAgICAg\nICA8ZXhpZjpDb2xvclNwYWNlPjE8L2V4aWY6Q29sb3JTcGFjZT4KICAgICAg\nICAgPGV4aWY6UGl4ZWxZRGltZW5zaW9uPjI1PC9leGlmOlBpeGVsWURpbWVu\nc2lvbj4KICAgICAgICAgPGRjOnN1YmplY3Q+CiAgICAgICAgICAgIDxyZGY6\nQmFnLz4KICAgICAgICAgPC9kYzpzdWJqZWN0PgogICAgICAgICA8eG1wOk1v\nZGlmeURhdGU+MjAxNC0xMS0xMFQwMToxMTo3ODwveG1wOk1vZGlmeURhdGU+\nCiAgICAgICAgIDx4bXA6Q3JlYXRvclRvb2w+UGl4ZWxtYXRvciAzLjM8L3ht\ncDpDcmVhdG9yVG9vbD4KICAgICAgPC9yZGY6RGVzY3JpcHRpb24+CiAgIDwv\ncmRmOlJERj4KPC94OnhtcG1ldGE+Clhh6GAAAAWFSURBVEgNtVVrbBRVFL6v\nmdmd2d3Odrvt0jaobLsktKVIKQ2iENEWAUtI/KERqglqwDQS0Cgi8Q8kGvyh\nMUAiCcZAQAIJigb9Qwo0QGPAvigEqLwkfbilr213Zh8z917vdrvb1mDiDzkz\nmcfJd757zrnnnAtCoRB4PIIeD22KlfwXagggApADCAHg4kp9cw5Z6vPfZYq6\nuLh4cGgwHotnwBBjRClFEGtLVWWVE87DhAB6z7bOWNEzUSvO0yshhOrr65vO\nno2Oj2dsU+8p6nA4DCyqaDLOlSFgbBT4XXlhPKB/4UGvICozACwGBBtwvqep\n57TIB2NmuwEA4px1tnYmzaSIJhVVRrDP5xsaGkr9QqjkO7wrda1G1Ra7jGuG\nYUV9J/32aptjO42fsIMU2OApqr6s8Wae7BeMACzgOEdmBuWWgEyyT20jo9Sz\nTJfLFFuijHN7kHp26PQZYSn8nYIJSwg45SBZlHR/5SYOggjRlno8K7TAhnyR\nMpgBT3rtcrnWrV3X1dKp7naylyCMYzdS0VZmeWyxh2mXpz2h2EOxq+gJStok\nhUjK0w5MMFOYoiqx+yYXzmTdSSQSl1paeILbOYDmxWAiYVoxexYVDgoYS2Mz\n3Ba3CgZmqQdUHJFwJVRrVdZosS0MFGPjZpTaNJ2TyUgty+rt67FGWOxDg/yg\nhN99SDkFGEo3pPymfB164yBhAWoD2+SxEJzbcPn1sc2jiS8tqMBoW5S7AfVZ\nRvOYcS+WcWBahQgVZXbsoqnkEmvctntth6kNbR0t7J3dcHB9R9W1HumuyGMl\nX1hxft7BHd9GwLje5SM+YDSbzn0ue8QaOy2KT7g8KVPFN6HgUhHhoiFEvRic\nmxyOo7brV+7X3n6hvu65+ctV1XX1/NVTF37sG+wjgKhLnKOHhjlj/DbLO+fD\nKgob4QzzTK9FjylzHfYY8Df6nbWq/WtS36gnOxLD0dHjx46DY1krsbPY0+CT\n6iQt4kp2J5ELDAwNxI1su6WQU1UlKkHES6qlnDc0RHDfxr6+N/tjNxOBIwFt\nuUtySAhgDNAySXm7Yv6iLUG5Av+1ulf2I/+uPJHx4eER0zSnFhdxi8nX3d2d\nVgljtVJlI3bsQTzHkxMsDba1tnlWud0NbijjZNhWbNbYxTe2FpyQo42X74rm\nwJjkb/PL5XLPWz1iKkynBumhijEuKSlBiCCA0mXs9XpramoENDWbIFFKHdrz\nmmuFG4e0PbIUAWh/WcU7s2c7ABKhKF4FQSRIysvLZVmeXCBNDSEkJKOasfQj\nfoKAdMmKXVH5W0GRe1pDQSjv3PmpmBxpm2xCYH6eo3Su1NGR0HVUGpTaOiyv\nTkTPYcS9OvTo/P6ftL/XXlTteNBDAwlUo/D2BLyDuCpjiOHgYHJxtdz6uzkS\nsdLU2eKD69er27c7jh7x+Avowipw6iRYUIXv3UGKrMx+ElRXG9s/Ypdaxg59\n57p2Hd/4w9b9TLmFN5XBpCkSBvr7+GuvksNH3bt39aSpsxXCnRrbu99cWC07\nnXjPHrNmiVReTp9dyq60Jz/+ZKipiR86/FBzgajBcr2kLOQI6Njn5mtXg8Ki\npKywBVVk0+bIiePRbAaz1KnSq31RHh6xFRmsqnMOD9POq7LXbzefG+jtMWUF\niUbCKTj65kA8UGiFSlHRLEd7u8PnF7ZwPMI2bHCsrHOmNn5CsgkBFy+AUFDZ\nu2+0pFRas0bZ/7XhCzgLA2Q0wmMxfvpnMQZ4+CH8/DPw0y8jLnduzLA9Hnz0\neyMYRFGT371jbHvfeeuGOBwyMlkhAE+cOOKZ/hBLils4KW6hyQYnPCKimqbB\n0hihkSaUApDxmrHUcOXTxkpm0Ue+RVZsnpox/5CJCT1TR+bMmSPOTZGsmfr/\n4e9vV5A936h1ocMAAAAASUVORK5CYII=\n")
  }

end
