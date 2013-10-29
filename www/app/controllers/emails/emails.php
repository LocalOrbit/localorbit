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
		if(!isset($values['hubname']))
			$values['hubname'] = $core->config['domain']['name'];
			
		$styles = array(
			'h1'=>'text-align: center;color: '.$this->options['email_p1a'].';border: '.$this->options['email_p1a'].' 1px solid;border-width: 4px 0px 18px 0px;font-size: 32px !important;padding: 15px 0px;font-weight: normal;',
			'h2'=>'border: '.$this->options['email_p1a'].' 1px solid;padding-bottom:4px;border-width: 0px 0px 2px 0px;',
			'h3'=>'font-weight: bold;font-size: 110%;margin: 8px 0px;',
			'h4'=>'font-weight: bold;margin: 8px 0px;',
			'a'=>'color: '.$this->options['p2c'].';',
			'th class="dt"' =>'font-family: Ubuntu, Arial, Sans Serif;text-align: left;padding: 4px 2px;background-color: #e3ebe7;font-weight: bold;color: #000;',
			'td class="dt"' =>'font-family: Ubuntu, Arial, Sans Serif;text-align: left;padding: 4px 2px;',
			'tr class="dt"' =>'background-color: #f2f5f4;',
			'tr class="dt1"'=>'background-color: #fff;',
			'table class="dt"' => 'border-collapse: collapse;width:100%;',
		);
		
		foreach($values as $key=>$value)
		{
			$src = str_replace('{'.$key.'}',$value,$src);
		}
		
		foreach($styles as $tag=>$style)
		{
			$src = str_replace('<'.$tag,'<'.$tag.' style="'.$style.'"',$src);
		}
		
		return $src;
	}
	
	public function send_email($subject,$to,$body='',$cc=array(),$from_email='',$from_name='')
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
		$email->save();


		# load the lib, set all properties
		# only use the parameters to override the from if needed.
		// core::load_library('core_phpmailer');
		// if($from_email=='')
		// {
		// 	$mail = new core_phpmailer(false);
		// }
		// else
		// {
		// 	$mail = new core_phpmailer(false,$from_email,$from_name);
		// }
		
		
		
		// $mail->IsHTML(true);

		// if(is_array($to))
		// 	foreach($to as $to_address)
		// 		$mail->AddAddress($to_address);
		// else
		// 	$mail->AddAddress($to);

		// $mail->Subject = $subject;
		// $mail->Body = $body;
		
		// if($from_name != '')
		// {
		// 	$mail->SetFrom('service@localorb.it',$from_name);
		// }
		
		// # send out the email, check for errors, email the errors if they occur
		// core::log('sending email to '.$to.': '.$subject);
		// $mail->Send();
		// if($mail->ErrorInfo != '')
		// {
		// 	core::log('email send failure: '.$mail->ErrorInfo);
		// 	$body = 'Error while trying to send email to '.$to.' with subject '.$subject;
		// 	$body .='<br />&nbsp;<br />'.$mail->ErrorInfo;
		// 	core_phpmailer::send_email('Error sending e-mail',$body,'mike@localorb.it','Mike Thorn');
		// }
		// else
		// {
		// 	core::log('email sent');
		// }
	}
	
	function email_start()
	{
		return '<div style="font-family: '.$this->options['font1'].';font-size: '.$this->options['font-size'].';line-height: 150%;color: '.$this->options['p4e'].';">';
	}
	
	function email_end()
	{
		return '</div>';
	}
	
	function footer($text=null,$domain_id=null)
	{
		global $core;
		if(is_null($text))
		{
			$text = 'For customer service please reply to this email or call 734.545.8100 ';
		}
		
		$img = image('logo-email',$domain_id);
		$foot  = '<div style="margin-top: 20px;color: '.$this->options['p4d'].';font-size: 90%;">'.$text.'</div>';
		$foot .= '<div style="text-align: center;margin-top: 10px;">';
			$foot .='<img src="http://'.$core->config['domain']['hostname'].$img.'" />';
			if(strpos($img,'/default') === false)
			{
				$foot .='<br /><img src="http://'.$core->config['domain']['hostname'].'/img/misc/poweredby_lo.png" />';
			}
		$foot .= '</div>';
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
					'Puget Sound Food Network'
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
					'Mike Thorn'
				);
				break;
		}
		core_ui::notification('E-mail sent');
		
		#echo('hi hi');
		#$this->send_email('testing now','mike@localorb.it');
	}
}

?>