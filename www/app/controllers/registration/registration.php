<?php

class core_controller_registration extends core_controller
{
	function process_invite()
	{
		global $core;
		
		core::log('here');
		core::load_library('crypto');
		$customer = core::model('customer_entity');
		$customer['email'] = $core->data['email'];
		$customer['org_id'] = $core->data['org_id'];
		$customer['first_name'] = $core->data['first_name'];
		$customer['last_name'] = $core->data['last_name'];
		$customer['password'] = core_crypto::encode_password($core->data['password']);
		$customer['email'] = $core->data['email'];
		$customer['created_at'] = core_format::date($core->config['time'],'db');
		$customer->save();
		core::process_command('auth/process');
		#core::redirect('dashboard','home');
	}

	function rules()
	{
		global $core;
		return new core_ruleset('regform',array(
			array('type'=>'min_length','name'=>'first_name','data1'=>2,'msg'=>$core->i18n['error:customer:firstname']),
			array('type'=>'min_length','name'=>'last_name','data1'=>2,'msg'=>$core->i18n['error:customer:lastname']),
			array('type'=>'valid_email','name'=>'email','msg'=>$core->i18n['error:customer:email']),
			array('type'=>'match_confirm_field','name'=>'email','data1'=>'email_confirm','msg'=>$core->i18n['error:customer:email-match']),
			array('type'=>'min_length','name'=>'password','data1'=>8,'msg'=>$core->i18n['error:customer:password']),
			array('type'=>'match_confirm_field','name'=>'password','data1'=>'password_confirm','msg'=>$core->i18n['error:customer:password-match']),
			array('type'=>'min_length','name'=>'address','data1'=>5,'msg'=>$core->i18n['error:address:address']),
			array('type'=>'min_length','name'=>'city','data1'=>2,'msg'=>$core->i18n['error:address:city']),
			array('type'=>'min_length','name'=>'postal_code','data1'=>5,'msg'=>$core->i18n['error:address:postalcode']),
			#array('type'=>'not_equal_to','name'=>'latitude','data1'=>0,'msg'=>$core->i18n['error:address:valid_address']),
			array('type'=>'is_checked','name'=>'tos_approve','data1'=>'on','msg'=>$core->i18n['error:registration:tos_approve']),
		));
	}

	function invite_rules()
	{
		global $core;
		return new core_ruleset('authform',array(
			array('type'=>'min_length','name'=>'first_name','data1'=>2,'msg'=>$core->i18n['error:customer:firstname']),
			array('type'=>'min_length','name'=>'last_name','data1'=>2,'msg'=>$core->i18n['error:customer:lastname']),
			array('type'=>'min_length','name'=>'password','data1'=>8,'msg'=>$core->i18n['error:customer:password']),
			array('type'=>'match_confirm_field','name'=>'password','data1'=>'password_confirm','msg'=>$core->i18n['error:customer:password-match']),
			array('type'=>'is_checked','name'=>'tos_approve','msg'=>$core->i18n['error:registration:tos_approve']),
		));
	}

	#insert into phrases (pcat_id,label,default_value,tags) values (3,'error:registration:tos_approve','You must agree to the Terms of Service','customer');

	function generate_fake_fields()
	{
		global $core;

		$core->session['spammer_field'] = 'f'.md5('stop, spammertime! '.time());
		$core->session['spammer_fake_fields']=array();
		$core->session['spammer_nums']  = array(
			rand(1,12),rand(1,12)
		);

		$fields = array();
		for ($i = 1; $i < 50; $i++)
		{
			$fake_field = 'f'.(md5('stop, spammertime! '.(time() + $i)));
			$fields[] = '<input type="text" style="display: none; width: 70px;" id="'.$fake_field.'" name="'.$fake_field.'" value="" />';
			$core->session['spammer_fake_fields'][] = $fake_field;
		}
		$fields[] = '<input type="text" style="display: none; width: 70px;" id="'.$core->session['spammer_field'].'" name="'.$core->session['spammer_field'].'" value="" />';

		# randomize the fields
		shuffle($fields);
		# turn on the only real field
		core::js('document.getElementById(\''.$core->session['spammer_field'].'\').style.display=\'inline\';');

		return $fields;
	}

	function checking_captcha()
	{
		global $core;

		# make sure that there are actually numbers stored in the captcha fields
		if(!is_numeric($core->session['spammer_nums'][0])
			|| !is_numeric($core->session['spammer_nums'][1])
			|| !is_numeric($core->data[$core->session['spammer_field']])
		)
			core_ui::validate_error($core->i18n['error:customer:captcha_error'],'regform',$core->session['spammer_field']);

		# now, check the math
		$result = intval($core->session['spammer_nums'][0]) + intval($core->session['spammer_nums'][1]);
		if($result != intval($core->data[$core->session['spammer_field']]))
		{
			core::log("spammer field check");
			core_ui::validate_error($core->i18n['error:customer:captcha_error'],'regform',$core->session['spammer_field']);
		}

		# woohoo!
		core::log('passed captcha!!!');
	}

	function check_unique($formname = 'regform',$not_entity_id=0)
	{
		global $core;
		$sql = '
			select entity_id
			from customer_entity
			where lower(email)=lower(\''.$core->data['email'].'\')
		';
		if($not_entity_id > 0)
		{
			$sql .= ' and entity_id <> '.$not_entity_id;
		}
		if(core_db::num_rows($sql))
		{
			core::log("non unique email");
			core_ui::validate_error($core->i18n['error:customer:unique_email'],$formname,'email');
		}
	}

	function process()
	{
		global $core;
		#core::log_data();
		#core::deinit();

		if (!($core->data['allow_sell'] || $core->data['allow_buyer'])) {
			core_ui::notification('Please select what you would like to do.');
			return;
		}

		# validate the data in various ways
		$this->rules()->validate();
		core::log('passed intial validation');
		$this->checking_captcha();
		core::log('passed captcha validation');
		$this->check_unique();
		core::log('passed unique validation');

		core::load_library('crypto');

		#$_SERVER['HTTP_HOST'] = core_db::col('select hostname from domains where domain_id='.$core->data['domain_id'],'hostname');

		# meddle with the data a bit
		if($core->data['company_name'] == '')
			$core->data['company_name'] = $core->data['first_name'] .' '.$core->data['last_name'];

		# load the domain's settings
		$domain = $core->config['domain'];

		# save to lo database
		$org = core::model('organizations');
		$org['parent_org_id'] = 0;
		$org['name']          = $core->data['company_name'];
		$org['domain_id']     = $core->data['domain_id'];
		$org['allow_sell']    = (intval($core->data['allow_sell']) == 0)?0:1;
		$org['orgtype_id']    = 3;
		$org['payment_allow_paypal']        = $domain['payment_default_paypal'];
		$org['payment_allow_purchaseorder'] = $domain['payment_default_purchaseorder'];
		$org['po_due_within_days'] = $domain['po_due_within_days'];
		$org['is_active']     = (intval($domain['autoactivate_organization'])==1)?1:0;
		$org->save();
		core::log('org created: '.$org['org_id']);

		$o2d = core::model('organizations_to_domains');
		$o2d['org_id'] = $org['org_id'];
		$o2d['domain_id'] = $core->config['domain']['domain_id'];
		$o2d['orgtype_id'] = 3;
		$o2d['is_home'] = 1;
		$o2d->save();

		# create the user
		$user = core::model('customer_entity');
		$user['first_name'] = $core->data['first_name'];
		$user['last_name']  = $core->data['last_name'];
		$user['email']      = $core->data['email'];
		$user['password']   = core_crypto::encode_password($core->data['password']);
		$user['org_id']     = $org['org_id'];
		$user['created_at'] = core_format::date($core->config['time'],'db');
		$user['is_active']  = intval($domain['autoactivate_organization']);

		$user->save();
		core::log('user created: '.$user['entity_id']);

		# create the organization's address
		$address = core::model('addresses');
		$address['org_id']  = $org['org_id'];
		$address['label']   = 'Default Location';
		$address['address'] = $core->data['address'];
		$address['city']    = $core->data['city'];
		$address['fax']     = $core->data['fax'];
		$address['postal_code'] = $core->data['postal_code'];
		$address['telephone']   = $core->data['telephone'];
		$address['region_id']   = $core->data['region_id'];
		$address['latitude']   = $core->data['latitude'];
		$address['longitude']   = $core->data['longitude'];
		$address['default_shipping']   = 1;
		$address['default_billing']   = 1;

		$address->save();
		core::log('address created: '.$address['address_id']);
		#core_ui::validate_error($core->i18n['error:customer:captcha_error']);

		# send email notifications
		# this will get all market managers
		$mms = core_db::col_array('
			select email
			from customer_entity
			where org_id in (
				select org_id
				from organizations_to_domains
				where orgtype_id=2
				and domain_id='.$core->config['domain']['domain_id'].'
			)
		');
		core::log('retrieved mm list');
		foreach($mms as $mm)
		{
			core::log('sending to '.$mm);
			core::process_command('emails/new_registrant_notification',false,
				$mm,
				$core->data['company_name'],
				$user['first_name'].' '.$user['last_name'],
				$core->data['email'],
				'https://'.$core->config['domain']['hostname'].'/app.php#!organizations-edit--org_id-'.$user['org_id'],
				((intval($core->data['allow_sell']) == 0)?'Buyer only':'Buyer and Seller'),
				$core->config['domain']['domain_id'],
				'https://'.$core->config['domain']['hostname'].'/app.php#!dashboard-home'
			);
		}
		
		
		core::process_command('emails/new_registrant',false,
			$core->data['email'],
			$user['first_name'],
			$this->generate_verify_link($core->config['domain']['hostname'],$user['entity_id']),
			$core->config['domain']['domain_id']
		);

		core::log('about to auth');

		# login and redirect to dashboard
		core::process_command('auth/process');
	}

	function generate_verify_link($hostname,$user_id)
	{
		return 'https://'.$hostname.'/app.php#!registration-verify_user--user_id-'.$user_id.'-key-'.$this->confirm_key_generate($user_id);
	}

	function verify_user()
	{
		global $core;
		lo3::require_login();
		if($core->data['user_id'] != $core->session['user_id'])
		{
			$this->already_logged_in();
		}

		core::log('tryign to verify user_id '.$core->data['user_id'].' using key '.$core->data['key']);

		if($this->confirm_key_verify($core->data['user_id'],$core->data['key']))
		{
			$cust = core::model('customer_entity')->load($core->data['user_id']);
			core::log('user loaded: '.$cust['org_id'].'/'.$cust['org_id']);
			$org = core::model('organizations')->load($cust['org_id']);

			$domain = core::model('domains')->load($org['domain_id']);
			core::log("domain is: ".$org['domain_id']);
			$cust['is_active'] = 1;
			$cust->save();
			core::model('events')->add_record('E-mail Confirmed',$core->data['user_id']);

			$core->session['is_active'] = 1;

			if($core->session['allow_sell'])
			{
				$email = 'emails/seller_welcome';
				if($org['is_active'] == 1)
				{
					$email .= '_activated';
				}
				core::process_command($email,true,
					$core->session['email'],
					$domain['hostname'],
					$core->session['first_name'],
					$org['domain_id']
				);
			}
			else
			{
				$email = 'emails/buyer_welcome';
				if($org['is_active'] == 1)
				{
					$email .= '_activated';
				}
				core::process_command($email,true,
					$core->session['email'],
					$domain['hostname'],
					$core->session['first_name'],
					'',
					$org['domain_id']
				);
			}
			page_header('Thank you!');
			?>
			You have successfully activated your account! <a href="app.php#!dashboard-home" onclick="core.go(this.href);">Click here</a> to go to your dashboard.
			<br />&nbsp;<br >
			<br />&nbsp;<br >
			<br />&nbsp;<br >

			<?php
		}
		else
		{
			$this->invalid_key();
		}
	}



	function confirm_key_generate($user_id)
	{
		global $core;
		return substr(md5($user_id.$core->config['registration']['activate_hash_secret']),0,10);
	}

	function confirm_key_verify($user_id,$to_test)
	{
		core::log($this->confirm_key_generate($user_id));
		return ($this->confirm_key_generate($user_id) == $to_test);
	}
}

?>