<?php 

class core_controller_emails extends core_controller 
{
	public function __construct($path)
	{
		#core::log('default controller constructor called: '.get_class($this).'/'.$path);
		$this->path = $path;
		$this->i18n = array();
		$this->rules = array();
		core::log('emails controller instantiated');
		$this->options = core::model('template_options')->get_options();
	}
	
	function handle_source($src,$values)
	{
		global $core;
		
		# add in more values
		if(!isset($values['hub_name']))
			$values['hub_name'] = $core->config['domain']['name'];
		
		foreach($values as $key=>$value)
		{
			$src = str_replace('{'.$key.'}',$value,$src);
		}
		
		return $src;
	}
	
	public function send_email($subject,$to,$body='',$cc=array(),$from_email='',$from_name='',$merge_vars='')
	{
		global $core;
		
		# check to see if we're forcing this email to go to a particular address
		if(isset($core->data['force_email']) && $core->data['force_email']!='')
			$to = $core->data['force_email'];

		if($from_email == '')
		{
			$from_email = $core->config['mailer']['From'];
		}
		if($from_name == '')
		{
			$from_name = $core->config['mailer']['FromName'];
		}
		
		# Previously this functionality used phpmailer. 
		# Now we're just going to write it to the db
		$email = core::model('sent_emails');
		$email['subject'] = $subject;
		$email['body'] = $body;

		if(is_array($to))
			$email['to_address'] = implode(',',$to);
		else
			$email['to_address'] = $to;

		$email['from_email'] = $from_email;
		$email['from_name']  = $from_name;
		$email['emailstatus_id'] = 1;

    if(is_array($merge_vars))
      $email['merge_vars'] = serialize($merge_vars);

		$email->save();
	}
	
	function email_start($domain_id=null)
	{
    global $core;

    if (!is_null($domain_id)) {
      $domain =  core::model('domains')->load($domain_id);
      $tagline = '&quot;'.$domain['custom_tagline'].'&quot;';
    } else {
      $tagline = '';
    }

    return '<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Email</title>
</head>
<body style="background: #e5e5e5; padding: 0; margin: 0;">
  <style>
    body {
      padding: 0;
      margin: 0
      color: #666;
      background: #e5e5e5;
    }
    a {
      color: #6e0206;
      text-decoration: none;
    }
    h1 {
      font: bolder 22px/1.5 "Helvetica Neue", Helvetica, Arial, sans-serif;
    }
    h2 {
      margin: 0;
      font: lighter 24px/1.25 "Helvetica Neue", Helvetica, Arial, sans-serif;
    }
    h3 {
      margin: 0;
      font: bold 16px/1.875 "Helvetica Neue", Helvetica, Arial, sans-serif;
    }
    dl {
      margin: 0;
    }
    dt {
      display: inline;
    }
    dd {
      display: inline;
      margin: 0;
      font-weight: bold;
    }
    th dl {
      display: inline-block;
      margin: 0;
      vertical-align: middle;
    }
    th dt {
      display: block;
      color: #6e0206;
      font: normal 18px/1.666 "Helvetica Neue", Helvetica, Arial, sans-serif;
    }
    th dd {
      display: inline;
      padding: 0;
      margin: 0;
      color: #575757;
      font-size: 14px;
    }
    table {
      width: 100%;
    }
    tfoot {
      font-weight: bold;
    }
      tfoot th {
        font-weight: bold;
        text-align: right;
      }
    th {
      font-weight: normal;
      text-align: left;
    }
    div.lo_body {
      padding: 0 0 50px;
      color: #666;
      background: #e5e5e5;
      font: normal 10px "Helvetica Neue", Helvetica, Arial, sans-serif;
      text-align: center;
    }
    p.lo_header {
      font: normal 10px "Helvetica Neue", Helvetica, Arial, sans-serif;
    }
    div.lo_content {
      border: solid 20px #fff;
      max-width: 540px;
      margin: 0 auto;
      color: #000;
      background: #fff;
      font: normal 18px/1.44 "Helvetica Neue", Helvetica, Arial, sans-serif;
      text-align: left;
    }
      a.lo_button {
        display: inline-block;
        padding: 0 8px;
        border: solid 1px #0d3459;
        border-top-color: #164c80;
        border-bottom-color: #041c32;
        border-radius: 5px;
        box-shadow: inset 0 1px 0 rgba(255,255,255,0.5), 0 1px 0 rgba(0,0,0,0.75);
        color: #fff;
        background: #356797;
        text-shadow: 0 2px 0 rgba(0,0,0,0.75);
      }
      a.lo_button_large {
        padding: 10px 25px;
        font-size: 18px;
      }
      a.lo_add_link {
        font-size: 14px;
      }
      a.lo_visit_link {
        display: block;
        font-size: 12px;
        font-weight: bold;
        text-align: right;
      }
      div.lo_blockquote_wrapper {
        position: relative;
        padding: 25px;
        margin: 25px 0;
        color: #666;
        font-size: 14px;
      }
        div.lo_blockquote_wrapper:before,
        div.lo_blockquote_wrapper:after {
          position: absolute;
          color: #d2d2d2;
          font: normal 62px "Proxima Nova", Times, "Times New Roman", serif;
        }
        div.lo_blockquote_wrapper:before {
          top: 0;
          left: 0;
          content: "&quot;";
        }
        div.lo_blockquote_wrapper:after {
          right: 0;
          bottom: 0;
          content: "&quot;";
        }
        div.lo_blockquote_wrapper blockquote {
          margin: 0;
        }
      div.lo_call_to_action {
        padding: 23px 23px 10px;
        margin: 0 0 25px;
        text-align: center;
        color: #666;
        background: #eee;
        font-size: 12px;
      }
      img.lo_org_logo {
        width: 120px;
      }
      p.lo_note {
        font-size: 14px;
        line-height: 2.1;
        text-align: center;
      }
      p.lo_slogan {
        color: #666;
        font-weight: lighter;
        text-align: right;
      }
      span.lo_availability {
        font-size: 12px;
      }
      span.lo_hint {
        display: block;
        font-size: 14px;
      }
      h2.lo_reference_number {
        margin-bottom: .5em;
        color: #6e0206;
        font-weight: bold;
      }
      span.lo_order_number {
        color: #6e0206;
        font-weight: bold;
      }
      table.lo_content_header {
        width: 100%;
      }
    table.lo_fresh_sheet {
      border-collapse: collapse;
      margin: 0 0 25px;
    }
      table.lo_fresh_sheet tr:nth-child(odd) {
        background: #eee;
      }
      table.lo_fresh_sheet td,
      table.lo_fresh_sheet th {
        padding: 13px;
      }
      table.lo_fresh_sheet td {
        text-align: right;
      }
      table.lo_fresh_sheet td a {
        font-weight: bold;
      }
      table.lo_fresh_sheet img {
        width: 48px;
        margin: 0 13px 0 0;
        vertical-align: middle;
      }
    table.lo_order {
      border-collapse: collapse;
      font-size: 14px;
    }
      table.lo_order td,
      table.lo_order th {
        padding: 4px 10px;
      }
      table.lo_order th {
        font-weight: bold;
        line-height: 1.7;
      }
      table.lo_order tbody tr:nth-child(odd) {
        background: #f7f7f7;
      }
      th.lo_vendor {
        font-style: italic;
      }
      td.lo_currency {
        text-align: right;
      }
      th.lo_currency {
        text-align: right;
      }
    table.lo_steps {
      padding: 25px;
      margin: 25px 0;
      background: #eee;
    }
      table.lo_steps td {
        padding: 6px;
        vertical-align: top;
      }
      td.lo_call_to_action {
        text-align: center;
      }
      span.lo_step {
        display: block;
        width: 2em;
        -webkit-border-radius: 50%;
        -moz-border-radius: 50%;
        border-radius: 50%;
        color: #c7c7c7;
        background: #fff;
        font: bold 18px/2em "Helvetica Neue", Helvetica, Arial, sans-serif;
        text-align: center;
      }
    td.lo_placed_by {
      text-align: right;
    }
    div.lo_footer {
      font-size: 12px;
    }
      img.lo_logo {
        height: 45px;
        margin: 20px 0 0;
      }
  </style>
  <div class="lo_body">
    <p class="lo_header">&nbsp;</p>
    <div class="lo_content">
    <!-- Content Header -->
      <a href="http://'.$core->config['domain']['hostname'].'/app.php#!dashboard-home" class="lo_visit_link">Visit the Market &#x2799;</a>
      <table class="lo_content_header">
        <tr>
          <td>
            <a href="http://'.$core->config['domain']['hostname'].'"><img src="http://'.$core->config['domain']['hostname'].image('logo-large', $domain_id).'" alt="" class="lo_org_logo"></a>
          </td>
          <td>
            <p class="lo_slogan">'.$tagline.'</p>
          </td>
        </tr>
      </table>';
	}
	
	function email_end()
	{
		return '</div></body></html>';
	}
	
	function footer($text=null,$domain_id=null)
	{
		global $core;
		if(is_null($text))
		{
			$text = 'For customer service please reply to this email or call 734.545.8100 ';
		}

    $foot = '<p class="lo_note"><em>'.$text.'</em></p>
          </div>

          <div class="lo_footer">
            <img src="http://'.$core->config['domain']['hostname'].image('logo-email').'" alt="Local Orbit Logo" class="lo_logo"><br>
            <strong>Powered by <a href="http://localorb.it/">Local Orbit</a></strong><br>
            <em class="lo_copyright">Copyright 2014. All Rights Reserved</em>
          </div>';
    return $foot;
	}

	function send_test()
	{
		global $core;
		
		
		switch($core->data['test'])
		{
			case 'registration_invite':
				$this->registration_invite(
					$core->data['force_email'],
					'http://testing.foodhubresource.com/#!registration-invite--org_id-653-email-iq.mthorn%2B2323423%40gmail.com-key-8bae9c3114',
					'Puget Sound Food Network',
					6
				);
				break;

			case 'order':
				$this->order(
					'mike@localorb.it',
					'mike thorn',
					'lo-309238402',
					array(
						array('seller_name'=>'Monsanto','product_name'=>'Tacos','qty_ordered'=>'1000','unit_plural'=>'yums','unit_price'=>1.00,'row_total'=>1000.00),
						array('seller_name'=>'Monsanto','product_name'=>'Delicious Soda','qty_ordered'=>'1000','unit_plural'=>'gulps','unit_price'=>0.75,'row_total'=>750.00),
						array('seller_name'=>'Organic or Die farms','product_name'=>'Slightly moldy avocados','qty_ordered'=>'50','unit_plural'=>'crates','unit_price'=>12.00,'row_total'=>600.00),
					),
					'purchaseorder',
					'2342A',
					6,
					'testingspringfield.localorb.it',
					'Springfield'
				);
				break;
			case 'order_seller':
				$this->order_seller(
					'mike@localorb.it',
					'mike thorn',
					'lfo-309238402',
					array(
						array('seller_name'=>'Monsanto','seller_org_id'=>3,'product_name'=>'Tacos','qty_ordered'=>'1000','unit_plural'=>'yums','unit_price'=>1.00,'row_total'=>1000.00),
						array('seller_name'=>'Monsanto','seller_org_id'=>3,'product_name'=>'Delicious Soda','qty_ordered'=>'1000','unit_plural'=>'gulps','unit_price'=>0.75,'row_total'=>750.00),
						array('seller_name'=>'Organic or Die farms','seller_org_id'=>6,'product_name'=>'Slightly moldy avocados','qty_ordered'=>'50','unit_plural'=>'crates','unit_price'=>12.00,'row_total'=>600.00),
					),
					'paypal',
					'2342A',
					6,
					'testingspringfield.localorb.it',
					'Springfield',
					3
				);
				break;
			case 'new_registrant':
				$this->new_registrant(
					'mike@localorb.it',
					'Mike',
					'http://testing.foodhubresource.com/#!registration-invite--org_id-653-email-iq.mthorn%2B2323423%40gmail.com-key-8bae9c3114',
					6
				);
				break;
			case 'unit_request':
				$this->unit_request(
					'mike thorn',
					'Robot',
					'Robots',
					'I want to sell robots, but there are no units. Actually the bigger problem is that I have no robots. But if you fix the unit problem then maybe I\'ll build one',
					'70',
					'Cheddar'
				);
				break;
			case 'product_request':
				$this->product_request(
					'mike@localorb.it',
					'mike thorn',
					'Chernobyl Chickens'
				);
				break;
			case 'new_registrant_notification':
				$this->new_registrant_notification(
						'detroiteasternmarket.localorb.it',
						'mike thorn farms',
						'mike thorn',
						'mike@localorb.it',
						'http://detroiteasternmarket.localorb.it/#!',
						'Buyer only',
						6,
						'http://detroiteasternmarket.localorb.it/app.php#!dashboard-home'
					);
				break;
			case 'buyer_welcome':
				$this->buyer_welcome(
					'mike@localorb.it',
					'Mike',
					'100 main st, ann arbor, mi',
					6
				);
				break;
			case 'buyer_welcome_activated':
				$this->buyer_welcome_activated(
					'mike@localorb.it',
					'Mike',
					'100 main st, ann arbor, mi',
					6
				);
				break;
			case 'seller_welcome':
				$this->seller_welcome(
					'mike@localorb.it',
					'detroiteasternmarket.localorb.it',
					'Mike',
					6
				);
				break;
			case 'seller_welcome_activated':
				$this->seller_welcome_activated(
					'mike@localorb.it',
					'detroiteasternmarket.localorb.it',
					'Mike',
					6
				);
				break;
			case 'org_activated_not_verified':
				$this->org_activated_not_verified(
					'mike@localorb.it',
					6
				);
				break;
			case 'org_activated_verified':
				$this->org_activated_verified(
					'mike@localorb.it',
					6
				);
				break;
			case 'reset_password':
				core::process_command('emails/reset_password',false,
					'mike@localorb.it',
					'password123',
					6
				);
				break;
			case 'email_change':
				$this->email_change(
					'mike@localorb.it',
					'mike+newemail@localorb.it',
					'Mike',
					6
				);
				#core_ui::notification('E-mail sent');
				break;
			case 'simple_test':
				$this->simple_test('mike thorn');
				#core_ui::notification('E-mail sent');
				break;
			case 'canceled_item_notification';
				$this->canceled_item_notification(
					'mike@localorb.it',
					'LO-12-017-0001734',
					'https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-1734',
					'Scrapple, Gluten Free',
					'Local Orbit',
					'Mike Thorn'
				);
				break;
			case 'manual_review_notification';
				$this->manual_review_notification(
					'mike@localorb.it',
					'LO-12-017-0001734',
					'https://testingannarbor-mi.localorb.it/app.php#!orders-view_order--lo_oid-1734',
					'Scrapple, Gluten Free',
					'Local Orbit',
					'Mike Thorn',
					6
				);
				break;
		}
		core_ui::notification('E-mail sent');
		
		#echo('hi hi');
		#$this->send_email('testing now','mike@localorb.it');
	}
}

?>