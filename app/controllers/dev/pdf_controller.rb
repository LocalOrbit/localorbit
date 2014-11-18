module Dev
  class PdfController < ApplicationController
    layout false

    def index
    end

    def fuh
      render text: "<h1>fuh</h1>", type: "text/html"
    end

    def ttp
      if params[:order_id]
      order_id = params.require(:order_id)

      order = Order.find(order_id)
      type = params[:type] || "table tent"
      include_product_names = params[:include_product_names] == "true"
      req = Struct.new(:base_url).new(request.base_url.sub("3000", "3500"))

      context = GenerateTableTentsOrPosters.perform(
        order: order,
        type: type,
        include_product_names: include_product_names,
        request: req
      )

      render text: context.pdf_result.data, content_type: "application/pdf"
      else
        render
      end
    end

    def mit
      html = File.read("tmp/mi_tierra_order.html")
      pdf_settings = {:page_size=>"letter", :margin_top=>0, :margin_right=>0, :margin_left=>0, :margin_bottom=>0}
      pdf_kit = PDFKit.new(html, pdf_settings)
      render text: pdf_kit.to_pdf, content_type: "application/pdf"
    end

    def logo_test
      output_type = :html if params[:html]
      logo_urls = [
        "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDYvMTQvMTQvMDQvMTAvMzYxL2xvZ29fbGFyZ2UuanBnIl1d?sha=f1311a8627e84c31",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDYvMjYvMTUvNTMvMjgvNzEvd2hvbGVzYWxlc3NmbWxvZ28ucG5nIl1d?sha=2a278cbe07a53092",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDYvMTMvMTUvNTkvNTUvMjkxL2xvZ29fbGFyZ2UuanBnIl1d?sha=4340a609cec5206d",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDYvMTgvMjEvNTMvNTAvNjg4L2xvZ29fbGFyZ2UuanBnIl1d?sha=616074a02d76cf64",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDYvMDQvMTkvMzMvNDMvMTYwL05HX0xvZ29fQm91bnR5X2Zyb21fdGhlX0NvdW50eS5qcGciXV0?sha=1ed4b0c6115bc7db",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDYvMTQvMTQvMjkvMTIvOTEvbG9nb19sYXJnZS5qcGciXV0?sha=a1bde15424388ffb",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDYvMTQvMTQvMzIvNDQvMTQxL2xvZ29fbGFyZ2UuanBnIl1d?sha=5f27a174dd5f5f27",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDcvMTgvMDEvMTMvMzAvMjg4L0JDRl9sb2dvX29yYW5nZV9hbmRfZ3JlZW4uanBnIl1d?sha=09f1e5d1efb09b28",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDQvMzAvMTYvMDMvNTMvNTUwL2xvZ29fbGFyZ2UucG5nIl1d?sha=74956370196478d1",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDQvMjUvMTAvMjAvNDMvNzU1L2FsbF90aGluZ3NfZm9vZF9yZXYzXzAyLmpwZyJdXQ?sha=49a588c5384b56d5",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDcvMjIvMjEvMDMvNDQvNTY2L0FkZWxhbnRlX011amVyZXNfbG9nb3R5cGVfZmluYWxfM18uSlBHIl1d?sha=5e477920fd4676d7",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDQvMTUvMjAvNTIvNTIvNDQzL2xvZ290ZWFsLnBuZyJdXQ?sha=823887f2ff815bb2",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDYvMjYvMTYvMDkvMzQvMzU1L1BPU2xvZ28ucG5nIl1d?sha=8c67a8c4ff79998d",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDcvMDgvMTUvMDIvNDEvMTkvbG9nb19sYXJnZS5qcGciXV0?sha=4862feed5c049bdb",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDYvMjYvMDMvNDcvNTcvMzQ2L05hdGl2ZVByb2RfbG9nby5qcGciXV0?sha=b233f02873dcba86",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMTAvMDYvMTkvNDQvMzcvNjkyL1N0TWFyeXNfTE9HTy5wbmciXV0?sha=a6d1b74e2c3267f2",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDUvMDcvMDgvMzQvMjAvNjc5L2xvZ29fbGFyZ2UuanBnIl1d?sha=ac02f564a982c800",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDkvMjUvMjEvMzIvMTgvNjY2L0FIQ19zYW1wbGVfbG9nb18ucG5nIl1d?sha=5f1619f8f94885a8",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDYvMjIvMjIvNDkvMjUvNzAzL1NXRkYuV2ViQmFubmVyLmpwZyJdXQ?sha=8579840aefff489f",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDcvMjkvMTMvMDIvNDMvODgwLzIwMTJfMDZfMjdfMTIuMTMuMDQuanBnIl1d?sha=de6d2548b9d48bcf",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDUvMDEvMTgvMTQvMjcvNDk3L2xvZ29fbGFyZ2UuanBnIl1d?sha=814cdb217401be64",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDYvMTgvMTYvMDIvMzUvODgvbG9nb19sYXJnZS5qcGciXV0?sha=3c6db7229b691e30",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDgvMTMvMTUvMTIvMzcvNTE3L2dhdGhlci5qcGciXV0?sha=12b9ab9024b66b0e",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDkvMTAvMDYvMjAvMDMvMTE3L2hhcHB5X3ZhbGxleV9mcmVzaF8xNF90X3NoaXJ0LmpwZyJdXQ?sha=30b1ce406f573324",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDYvMjYvMTUvMjUvMzMvMjkxLzIwMTJfMDZfMjdfMTIuMTMuMDQuanBnIl1d?sha=e3754aacf27358dd",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDYvMTYvMTcvMjcvMTcvODU2L3NzZm1fYmxhY2sucG5nIl1d?sha=563096bb85925e61",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDkvMDkvMTAvNTAvMzUvNzk5L2dyZWVuYmF5Zm9vZGh1Yi5KUEciXV0?sha=e116f950571c52bb",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDgvMjIvMTYvMDIvNDAvMTU1L2Zhcm0ydGFibGVfbG9nby5qcGciXV0?sha=c2686231592116df",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDUvMDYvMTQvMjEvMDkvMjI4L2xvZ29fbGFyZ2UucG5nIl1d?sha=15597edd2c2936e1",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDgvMjAvMTUvNTgvMTkvNzMwL29zaGtvc2hmb29kaHViLmpwZyJdXQ?sha=798aeb0e1185bcb5",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDkvMjkvMjMvNDgvMDYvODQyL2Jyb29rLnBuZyJdXQ?sha=3b7dfea5817cfbbe",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDcvMTUvMTgvMTMvMDQvNTkvUkVWX3VyYmFuZm9vZHByb2plY3QuanBnIl1d?sha=9ccb2c3d5f288bb3",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDYvMTgvMjEvNTQvMzIvMjA1L2xvZ29fbGFyZ2UuanBnIl1d?sha=8e5dec18c9465337",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDkvMjkvMTgvMzQvMTkvOTM3L01hcmluX0xvZ28ucG5nIl1d?sha=332a119b78f4c83f",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDkvMjIvMjMvNDkvMzgvMzYyL1JBSV9TYW1wbGVfTG9nb18ucG5nIl1d?sha=630731ed94e35896",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDcvMTYvMjAvNDcvMzEvMjIwL0xJTkNfRm9vZHNfTG9nb19GaW5hbC5wbmciXV0?sha=0b3abf57f03d120b",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMTAvMDYvMTUvMzIvNDQvODk2L2hlYWR3YXRlcl9sb2dvX2hpZ2hyZXMucG5nIl1d?sha=f1d887c5cd0b9c8e",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDUvMzEvMTMvNDMvNTQvNjI4L2xvZ29fbGFyZ2UuanBnIl1d?sha=22efa1a88e8fbc2f",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMTAvMTYvMjIvNDIvNTgvNzY5L29yZGVyYm9hcmQucG5nIl1d?sha=41aa9a407fe57124",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDYvMTQvMTUvNDEvMDkvMTU0L2xvZ29fbGFyZ2UuanBnIl1d?sha=448bb1e6fb2c40ea",
       "http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDcvMjIvMjEvMDMvNDIvMjE3L2ZpbGUiXV0?sha=779d14e5b63cd85f"
      ]

      sections = logo_urls.map do |logo|
        section=<<-EOS
            <div class="container">

        <section class="header">
              <div class="productContent"><h1 class="headerPosterText">Stone Fruit</h1><h4>from <span style="text-decoration:underline;">local</span> producers!</h1></h4></div>
        </section>

        <section class="farm-details">
           <div class="arrow-down"></div>
           <h2 class="farm-name">Boettcher Farm</h2>
           <div class="farm-location">
              <span>Durand, MI</span>
                <span>|</span>
                <span>-83.968561,42.9255519</span>
              <br><br><br>
           </div>
        </section>

        <section class="farm-content">
           <div style="float:left; width:50%;">
              <ul style="float:right;text-align:center;">
                <li><img alt="W1siziisijiwmtqvmduvmdcvmdgvmzavntavnte0lzewljmymc4ynjaucg5nil1d?sha=63b266d47c0e9a0d" src="http://app.localtest.me:3500/media/W1siZiIsIjIwMTQvMDUvMDcvMDgvMzAvNTAvNTE0LzEwLjMyMC4yNjAucG5nIl1d?sha=63b266d47c0e9a0d" /></li>
                <li><img alt="320x200@2x" src="http://api.tiles.mapbox.com/v3/localorbit.i0ao0akd/pin-s-circle(-83.968561,42.9255519)/-83.968561,42.9255519,9/320x200@2x.png" /></li>
           </ul>
           </div>
           <div style="float:left; width:50%;">
              <br>
                <h4>Who We Are</h4>
                <p>We are a family farm that started because we love the country and wanted to grow our own food. This evolved into a business mainly by word of mouth. We now grow free range chickens, heritage turkeys, and some of the best vegetables around! Yes, they really are!</p>
           </div>

           <span><img alt="Lo circle lo" src="http://app.localtest.me:3500/assets/table_tents_and_posters/LO_Circle_lo.png" />Powered by <strong>Local Orbit</strong></span>
        </section>

        <section class="footer">
          <table class="footer-table">
          <tbody>
          <tr>
           <td class="footer-image-holder">
              <img src="#{logo}" />
           </td>
           <td class="market-info">
              <h5>Brought to you by</h5>
              <h4>Springfield Demo Market</h4>
              <span>Great food, from producers you trust.</span>
           </td>
           </tr>
           </tbody>
           </table>
        </section>

        </div>
        EOS
      end

      all_sections = []
      if output_type == :html
        all_sections =  sections.join("<hr>")
      else
        all_sections =  sections.join("")
      end

     html=<<-EOH
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8">
    <script src="http://app.localtest.me:3500/assets/jquery.js"></script>
    <script src="http://app.localtest.me:3500/assets/pdf_resizer.js"></script>
  </head>
  <body style='margin: 0; padding: 0;'>
    <style>
      .container{
0       max-width:960px;
        font-family: 'Helvetica', sans-serif;
        margin:0;
        padding:0;
        font-size: 16px;
        min-height: 1030px;
        max-height: 1030px;
        overflow:hidden;
        page-break-after: always;
      }
     section{float:left; width: 100%;}

     .header{
       background:#3F3E40;
       background-image:url("http://app.localtest.me:3500/assets/table_tents_and_posters/Group.png");
       color:#E3E3E4;
       text-align:center;
       font-size:200%;
       position:relative;
       background-size:cover;
       background-position:center center;
       height:190px;
       width:100%;
       overflow: hidden;
     }

    .productContent {
      display: inline-block;
      width: 90%;
    }

    h1.real-food {
      font-size:64px;
      margin-top:25px;
      line-height: 122%;
    }
    h1.headerPosterText{
      padding:5px;
      margin-bottom: 0px;
      font-size:48px;
      margin-top:5%;
      line-height: 125%;
    }
    .arrow-down{width: 0; height: 0; border-left: 62px solid transparent;
                 border-right: 62px solid transparent; border-top: 22px solid; margin: 0 auto;margin-top:-1px;}
    .header h4{margin-top: 0px;}
    .farm-details{color:#3F3E40;text-align:center;background:#E3E3E4;background-image:url("http://app.localtest.me:3500/assets/table_tents_and_posters/map.png"); position:relative;background-size:cover; background-position:center center;font-size:70%;line-height:175%;height:121px;overflow:hidden;}

    .farm-details h2{font-size:300%;margin: 2% 0 1%;}
    .farm-location{font-weight:bold;font-size:116%;}

    .farm-content{padding: 6% 0; position: relative;height:510px;overflow: hidden;text-align: left;}
    .farm-content p, .farm-content h4{padding:0 25% 0 6%; font-size: 100%;}
    .farm-content p {height: 450px; overflow: hidden;}
    .farm-content span{font-size:60%; padding-right:2%;position:absolute; bottom:0;right:0;z-index:9999999;}
    .farm-content span img{ width:6px; width:20px; padding-right: 4px; padding-bottom: 3px; vertical-align: middle;}
    .farm-content ul{float:right; list-style:none;}
    .farm-content li img{max-width:320px;max-height:200px;margin: 3% 0;}


    .footer{
      background:#3F3E40;
      background-image:url("http://app.localtest.me:3500/assets/table_tents_and_posters/Group.png");
      color:#FEFEFE;
      background-size:cover;
      background-position:center center;
      margin-top: 5px;
      min-height: 110px;
    }
    table.footer-table {
      width: 99%;
      height: 99%;
    }

    .footer h5{
      margin:3% 0 1%;
      text-transform:uppercase;
      border-bottom:1px solid;
      color:#8E8C8E;
      font-size: 80%;
    }
    .footer h4{
      line-height: 70%;
      margin: 3% 0 2%;
      font-size:140%;
    }
    .footer span{
      font-size:100%;
    }

    .footer .footer-image-holder {
      width:22%;
      text-align:center;
      vertical-align:middle;
      padding-top: 5px;
      // padding-right:20px;
    }
    .footer .footer-image-holder img {
      max-width: 150px;
      max-height: 90px;

      background:#ffffff;
      border: 1px solid #dfdfdf;
    }
    .footer .market-info {
    }


  </style>
  #{all_sections}

</body>
</html>
        
      EOH

      if output_type==:html
        render text: html, content_type: "text/html"
      else
        pdf_settings = {:page_size=>"letter", :margin_top=>0, :margin_right=>0, :margin_left=>0, :margin_bottom=>0}
        pdf_kit = PDFKit.new(html, pdf_settings)
        render text: pdf_kit.to_pdf, content_type: "application/pdf"
      end
    end
  end
end
