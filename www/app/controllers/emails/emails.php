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
    core_email::send($subject,$to,$body='',$cc=array(),$from_email='',$from_name='',$merge_vars='');
	}
	
	function email_start($domain_id=null)
	{
    return core_email::header($domain_id);
	}

	function email_end($text=null)
	{
		global $core;
    return core_email::footer($text);
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