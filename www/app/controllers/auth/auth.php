<?php

class core_controller_auth extends core_controller
{
	function unlock_pin()
	{
		global $core;
		
		'all_metrics';
		$area = ($core->data['custom_unlock_area'] == '')?'main_save_buttons':$core->data['custom_unlock_area'];
		
		if($core->data['sec_pin'] == $core->config['sec_pin'])
		{
			$core->session['sec_pin'] = 1;
			core::js("$('.unlock_area,#unlock_area,#".$area."').toggle();");
		}
		else
		{
			core_ui::validate_error('Incorrect pin.',$core->data['formname'],'sec_pin');
		
		}
		core::deinit();
	}
	
	function rules()
	{
		global $core;
		return new core_ruleset('authform',array(
			array('type'=>'valid_email','name'=>'email','msg'=>$core->i18n['error:customer:email']),
			array('type'=>'min_length','name'=>'password','data1'=>8,'msg'=>$core->i18n['error:customer:password']),
		));
	}
	
	function process_reset()
	{
		global $core;
		
		$this->reset_rules()->validate();
		
		
		$cust = core::model('customer_entity')->loadrow_by_email($core->data['username']);
		$org  = core::model('organizations')->load($cust['org_id']);
		if(intval($cust['entity_id']) > 0)
		{
			core::load_library('crypto');
			$new_pass = core_crypto::generate_password();
			core::process_command(
				'emails/reset_password',
				false,
				$core->data['username'],
				$new_pass,
				$org['domain_id']
			);
			$cust['password'] = core_crypto::encode_password($new_pass);
			$cust->save();
			$this->forgot_confirmation();
		}
		else
		{
			core_ui::error('Could not locate a user with this E-mail');
		}
	}
	
	function reset_rules()
	{
		global $core;
		return new core_ruleset('resetpass',array(
			array('type'=>'valid_email','name'=>'username','msg'=>$core->i18n['error:customer:email'])
		));
	}
	
	function process()
	{
		global $core;
		
		#core::log(print_r($core->config,true));
		$core->data['email'] = trim($core->data['email']);
		$core->data['password'] = trim($core->data['password']);
		
		$user = core::model('customer_entity')->authenticate(
			$core->data['email'],
			$core->data['password']
		);
		
		if($user['entity_id'] == 0)
		{
			core::model('events')->add_record('Login Failed',0,0,$core->data['email']);
			header('Location: /login.php?login_fail=1');
			exit();
			core_ui::validate_error($core->i18n['error:customer:login_fail'],((is_numeric($core->data['domain_id']))?'regform':'authform'),'password');		
			
		}
		else if($user['org_is_enabled'] == 0 || $user['is_enabled'] == 0)
		{
			core::model('events')->add_record('Login Failed',0,0,$core->data['email'],'User or Org is suspended');			
			header('Location: /login.php?account_suspended=1');
			exit();
			core_ui::validate_error($core->i18n['error:customer:account_suspended'],((is_numeric($core->data['domain_id']))?'regform':'authform'),'email');		
		}
		else
		{
			$core->session['org_id']     = $user['org_id'];
			$core->session['login_note_viewed']     = $user['login_note_viewed'];
			$core->session['is_active']  = $user['is_active'];
			$core->session['org_is_active']  = $user['org_is_active'];
			$core->session['org_name']   = $user['name'];
			$core->session['domain_ids'] = $user['domain_ids'];
			$core->session['hub_name']   = $user['hub_name'];
			$core->session['hub_detailed_name']   = $user['hub_detailed_name'];
			$core->session['user_id']    = $user['entity_id'];
			$core->session['group_id']   = $user['group_id'];
			$core->session['store_id']   = $user['store_id'];
			$core->session['hostname']   = $user['hostname'];
			$core->session['first_name'] = $user['first_name'];
			$core->session['last_name']  = $user['last_name'];
			$core->session['email']      = $user['email'];
			$core->session['buyer_type'] = $user['buyer_type'];
			$core->session['allow_sell'] = $user['allow_sell'];
			$core->session['time_offset']= $user['offset_seconds'] + (3600 * $user['do_daylight_savings']);
			$core->session['tz_name']    = $user['tz_name'];
			$core->session['home_domain_id'] = $user['home_domain_id'];
			$core->session['all_domains'] = $user['all_domains'];
			$core->session['login_note_viewed'] = $user['login_note_viewed'];
			$core->session['domains_by_orgtype_id'] = $user['domains_by_orgtype_id'];

			# figure out what the final hostname should be
			$final_hostname = $core->session['hostname'];
			
			#if the user logged in on anonymous shopping hub, don't change hubs
			if($core->config['domain']['feature_allow_anonymous_shopping'] == 1)
			{
				$final_hostname = $core->config['domain']['hostname'];
					
				# also, change over the user's cart
				core_db::query('
					update lo_order set
					org_id='.intval($core->session['org_id']).' 
					where session_id=\''.session_id().'\' 
					and org_id=0 
					and ldstat_id=1;
				');
			}

			core::model('events')->add_record('Login');
			
			#core::log('session data: '.print_r($core->data,true));
			core::log('here: '.$core->data[$core->session['spammer_fake_fields'][0]]);
			if(isset($core->data[$core->session['spammer_field']]) && $core->data[$core->session['spammer_field']] != '')
			{				
				core::log('reg redirect');
				if(
					$core->session['allow_sell'] == 0
				)
				{
					core::js('location.href=\'https://'.$final_hostname.'/'.$core->config['app_page'].'#!catalog-shop--show_news-yes\';');
					core::deinit();
				}
				else
				{
					core::js('location.href=\'https://'.$final_hostname.'/'.$core->config['app_page'].'#!dashboard-home\';');
					core::deinit();
				}
			}
			else if(isset($core->data['postauth_url']) && $core->data['postauth_url'] != '')
			{
				header('Location: '.$core->data['postauth_url'].'-redirect-1');
				exit();
				#core::js('location.href=\''.;');			
			}
			else{
				# buyers who are fully activated should be sent directly to the catalog
				if(
					in_array($core->session['home_domain_id'],$core->session['domains_by_orgtype_id'][3]) && 
					$core->session['is_active'] == 1 && 
					$core->session['org_is_active'] == 1 && 
					$core->session['allow_sell'] == 0
				)
				{
					header('Location: https://'.$final_hostname.'/'.$core->config['app_page'].'#!catalog-shop--show_news-yes');
					exit();
					core::js('core.navState={};location.href=\'\';');
				}
				else
				{
					header('Location: https://'.$final_hostname.'/'.$core->config['app_page'].'#!dashboard-home');
					core::js('core.navState={};location.href=\'https://'.$final_hostname.'/'.$core->config['app_page'].'#!dashboard-home\';');
				}
			}
			core::deinit();
		}
	}
	
	function logout()
	{
		global $core;
		core::log('logging out');
		core::model('events')->add_record('Logout');
			
		core::process_command_list('session-destroy');
		session_destroy();
		core_session::init();
		#$core->session = array('user_id' => 0);
		core::js('core.navState={};location.href=\'/login.php\';');
		core::deinit();
		#core::process_command('auth/form',false);
	}
	
	function loginas()
	{
		global $core;
		
		core::log('attempting admin login as '.$core->data['user_id']);
		$user = core::model('customer_entity');

		$user->autojoin(
			'left',
			'organizations',
			'(customer_entity.org_id=organizations.org_id)',
			array(
				'organizations.name as org_name',
				'organizations.is_active as org_is_active',
				'organizations.buyer_type',
				'organizations.allow_sell'
			)
		);
		$user->autojoin(
			'left',
			'organizations_to_domains',
			'(organizations_to_domains.org_id=organizations.org_id and is_home=1)',
			array('organizations_to_domains.orgtype_id')
		);
		$user->autojoin(
			'left',
			'domains',
			'(domains.domain_id=organizations_to_domains.domain_id and organizations_to_domains.is_home=1)',
			array('domains.hostname','domains.domain_id','domains.name as hub_name','domains.detailed_name as hub_detailed_name','domains.do_daylight_savings')
		);
		$user->autojoin(
			'left',
			'timezones',
			'(domains.tz_id=timezones.tz_id)',
			array('offset_seconds','tz_name')
		);
		$user->load($core->data['entity_id']);
		
		$core->session['user_id']    = $user['entity_id'];
		$core->session['login_note_viewed']     = $user['login_note_viewed'];
		$core->session['org_name']   = $user['name'];
		$core->session['org_id']     = $user['org_id'];
		$core->session['hub_name']   = $user['hub_name'];
		$core->session['hub_detailed_name']   = $user['hub_detailed_name'];
		$core->session['group_id']   = $user['group_id'];
		$core->session['store_id']   = $user['store_id'];
		$core->session['hostname']   = $user['hostname'];
		$core->session['first_name'] = $user['first_name'];
		$core->session['last_name']  = $user['last_name'];
		$core->session['email']      = $user['email'];
		$core->session['buyer_type'] = $user['buyer_type'];
		$core->session['allow_sell'] = $user['allow_sell'];
		$core->session['is_active'] = $user['is_active'];
		$core->session['time_offset'] = $user['offset_seconds'] + (3600 * $user['do_daylight_savings']);
		$core->session['tz_name'] = $user['tz_name'];
		$core->session['org_is_active'] = $user['org_is_active'];
		$core->session['login_note_viewed'] = $user['login_note_viewed'];
		
		$core->config['navstate'] = array();
	
		list(
			$core->session['home_domain_id'],
			$core->session['all_domains'],
			$core->session['domains_by_orgtype_id']
		) = core::model('customer_entity')->get_domain_permissions( $user['org_id']);
		
		
		core::model('events')->add_record('Login');
		
		if(
			in_array($core->session['home_domain_id'],$core->session['domains_by_orgtype_id'][3]) && 
			$core->session['is_active'] == 1 && 
			$core->session['org_is_active'] == 1 && 
			$core->session['allow_sell'] == 0
		)
		{
			core::js('core.navState={};location.href=\'https://'.$core->session['hostname'].'/'.$core->config['app_page'].'#!catalog-shop--show_news-yes\';');
		}
		else
		{
			core::js('core.navState={};location.href=\'https://'.$core->session['hostname'].'/'.$core->config['app_page'].'#!dashboard-home\';');
		}
	
		core::deinit();
	}
	
	function zendesk_work()
	{
		global $core;
		
		if($core->session['user_id'] == 0)
		{
			#print_r($core->config);
			$core->session['postauth_url'] = '/app/auth/zendesk_work?';
			core::log('setting postauth url to '.$core->session['postauth_url']);
			header('Location: /app.php#!auth-form');
			exit();
		}
		else
		{
		
			$sFullName = $core->session['first_name']." ".$core->session['last_name'];
			$sEmail = $core->session['email'];
			/* 
			 * These are used if we want to give an ID other than e-mail address or a group organization 
			 * We may want to use the sOrganization later to distiguish between buyers and sellers.
			 */
			/* $sExternalID = ""; */
			$sExternalID = $core->session['user_id'];
			#$sExternalID = '';
			

			 /* Insert the Authentication Token here */
			$sToken = 'Jgk5oJWgqPmdjVnPyJBKMKWP7KjeqWk9oTZwWffH6EwHihUT';

			 /* Insert your account prefix here. If your account is yoursite.zendesk.com: */
			$sUrlPrefix = "localorbit";

			 /* Build the message */
			$sTimestamp = isset($_GET['timestamp']) ? $_GET['timestamp'] : time();
			$sMessage = $sFullName.$sEmail.$sExternalID.$sToken.$sTimestamp;
			$sHash = MD5($sMessage);

			/* $sso_url = "http://".$sUrlPrefix.".zendesk.com/access/remote/?name=".$sFullName."&email=".$sEmail."&external_id=".$sExternalID."&organization=".$sOrganization."&timestamp=".$sTimestamp."&hash=".$sHash; */
			$sso_url = "http://".$sUrlPrefix.".zendesk.com/access/remote/?name=".urlencode($sFullName)."&email=".urlencode($sEmail)."&timestamp=".$sTimestamp."&hash=".$sHash.'&external_id='.urlencode($sExternalID);
			//header("Location: ".$sso_url);
			core::log('sso url: '.$sso_url);
			header("Location: ".$sso_url);
			exit();	
		}
	}
}

?>