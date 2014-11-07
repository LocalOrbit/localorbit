class Deliveries::PackingLabelsController < ApplicationController

  def show
    # if params[:delivery_id] == 'test' and params[:id] == 'test'
    #   pages = go_build_good_test_data
    # end
    # spike
    allen_market_logo = "http://app.lodev.me:3500/media/W1siZiIsIjIwMTQvMDYvMTMvMTUvNTkvNTUvMjkxL2xvZ29fbGFyZ2UuanBnIl0sWyJwIiwidGh1bWIiLCI2MDB4MjAwXHUwMDNlIl1d?sha=f5381df9c32271a0"

    page = { 
        a: { 
          template: "avery_labels/order",
          data: {
            order: {
              deliver_on: "October 18, 2014",
              order_number: "LO-14-ALLENMARKETPLACE-000002",
              buyer_name: "Ah Vue",
              market_logo_url: allen_market_logo,
            },
            qr_code_url: "http://chart.apis.google.com/chart?cht=qr&chs=300x300&chl=test&chld=H|0"
          }
        },

        b: { 
          template: "avery_labels/vertical_product",
          data: {
            order: {
              deliver_on: "October 18, 2014",
              order_number: "LO-14-ALLENMARKETPLACE-000002",
              buyer_name: "Ah Vue",
              market_logo_url: allen_market_logo,
            },
            qr_code_url: "http://chart.apis.google.com/chart?cht=qr&chs=300x300&chl=test&chld=H|0",
            product: {
              product_name: "Gold Rush Apples",
              quantity: 1,
              unit_desc: "each",
              lot_desc: "Lot #845",
              producer_name: "Hillcrest Farms"
            },   
          }
        },

        c: { 
          template: "avery_labels/vertical_product",
          data: {
            order: {
              deliver_on: "October 18, 2014",
              order_number: "LO-14-ALLENMARKETPLACE-000002",
              buyer_name: "Ah Vue",
              market_logo_url: allen_market_logo,
            },

            qr_code_url: "http://chart.apis.google.com/chart?cht=qr&chs=300x300&chl=test&chld=H|0",
            product: {
              product_name: "Giant Pumpkins",
              unit_desc: "each",
              quantity: 1,
              lot_desc: nil,
              producer_name: "Robinette's Orchard"
            },   
          }
        },

        d: { 
          template: "avery_labels/vertical_product",
          data: {
            order: {
              deliver_on: "October 18, 2014",
              order_number: "LO-14-ALLENMARKETPLACE-000002",
              buyer_name: "Ah Vue",
              market_logo_url: allen_market_logo,
            },
            qr_code_url: "http://chart.apis.google.com/chart?cht=qr&chs=300x300&chl=test&chld=H|0",
            product: {
              product_name: "Giant Carrots",
              unit_desc: "stuff",
              quantity: 24,
              lot_desc: nil,
              producer_name: "Robinette's Orchard"
            },   
          }
        }
      }

    page2 = {
      a: page[:b],
      b: page[:c],
      c: page[:a],
    }
    pages = [ page, page2 ]

    context = GeneratePdf.perform(
      request: RequestUrlPresenter.new(request),
      template: "avery_labels/labels", 
      pdf_size: { page_size: "letter" },
      params: {
        pages: pages
      })
    
    render text: context.pdf_result.data, content_type: "application/pdf"
  end
end
