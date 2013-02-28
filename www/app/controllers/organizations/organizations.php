<?php

class core_controller_organizations extends core_controller
{
	function add_rules()
	{
		global $core;
		return new core_ruleset('organizationsForm',array(
			array('type'=>'min_length','name'=>'name','data1'=>2,'msg'=>$core->i18n['error:organizations:name']),
			array('type'=>'min_length','name'=>'address','data1'=>5,'msg'=>$core->i18n['error:address:address']),
			array('type'=>'min_length','name'=>'city','data1'=>2,'msg'=>$core->i18n['error:address:city']),
			array('type'=>'min_length','name'=>'postal_code','data1'=>5,'msg'=>$core->i18n['error:address:postalcode']),
		));
	}

	function add_managed_hub()
	{
		global $core;

		lo3::require_orgtype('admin');

		# save the new row to the db
		$data = core::model('organizations_to_domains');
		$data['org_id'] = $core->data['org_id'];
		$data['domain_id'] = $core->data['domain_id'];
		$data['orgtype_id'] = 2;
		$data->save();

		# refresh various UI elements
		core::js("core.ui.dataTables['noncurrentdomains'].filterStates['noncurrentdomainsname'] = '';");
		core::js("$('#noncurrentdomains__filter__noncurrentdomainsname').val('');");
		core::js("org.toggleNewHubTable();");
		core_datatable::js_reload('currentdomains');
		core_datatable::js_reload('noncurrentdomains');
		core_ui::notification('hub added',false);
	}

	function delete_managed_hubs()
	{
		global $core;
		lo3::require_orgtype('admin');

		core_db::query('
			delete from organizations_to_domains
			where org_id='.intval($core->data['org_id']).'
			and domain_id in ('.$core->data['domain_ids'].')
		');

		core::js('document.organizationsForm.checkall_domainids.checked=false;');
		core_datatable::js_reload('currentdomains');
		core_datatable::js_reload('noncurrentdomains');
		core_ui::notification('hubs removed',false);
	}

	function save_payment_method()
	{
		global $core;
		core::load_library('crypto');

		if($core->data['org_id'] != $core->session['org_id'])
			lo3::require_orgtype('market');

		core::log(print_r($core->data,true));
		$pm = core::model('organization_payment_methods')
			->import_fields('opm_id','label','name_on_account','org_id');

		if($core->data['nbr1'] != '' && strpos($core->data['nbr1'],'*')===false)
		{
			$pm['nbr1'] = core_crypto::encrypt($core->data['nbr1']);
			$pm['nbr1_last_4'] = substr($core->data['nbr1'],strlen($core->data['nbr1'])-4,4);
		}
		if($core->data['nbr2'] != '' && strpos($core->data['nbr2'],'*')===false)
		{
			$pm['nbr2'] = core_crypto::encrypt($core->data['nbr2']);
			$pm['nbr2_last_4'] = substr($core->data['nbr2'],strlen($core->data['nbr2'])-4,4);
		}
		core::log(print_r($pm->__data,true));

		$pm->save();



		core_datatable::js_reload('payment_methods');

		core_ui::notification('bank account saved',false);
	}
	
	function set_primary_account()
	{
		global $core;
		
		if($core->data['org_id'] != $core->session['org_id'])
			lo3::require_orgtype('market');
		
		core_db::query('update organizations set opm_id='.intval($core->data['opm_id']).' where org_id='.intval($core->data['org_id']));
		
		core_datatable::js_reload('payment_methods');

		core_ui::notification('Default set',false);
	}


	function delete_payment_methods()
	{
		global $core;
		core_db::query('delete from organization_payment_methods where opm_id in ('.$core->data['opm_ids'].');');
		core_datatable::js_reload('payment_methods');

		core_ui::notification('bank accounts deleted');
	}

	function set_home_hub()
	{
		global $core;
		lo3::require_orgtype('admin');

		core_db::query('
			update  organizations_to_domains
			set is_home=0
			where org_id='.intval($core->data['org_id'])
		);
		core_db::query('
			update  organizations_to_domains
			set is_home=1
			where org_id='.intval($core->data['org_id']).'
			and domain_id='.intval($core->data['domain_id'])
		);
		core_datatable::js_reload('currentdomains');
		core_ui::notification('home hub set',false);
	}

	function get_filtered_orgs()
	{
		global $core;
		$orgs = core::model('organizations')
			->collection()
			->sort('name');
		if($core->data['sellers_only'] == 1)
		{
			$orgs->filter('allow_sell',1);
		}
		if($core->data['domain_id'] > 0)
		{
			$orgs->filter('organizations_to_domains.domain_id',$core->data['domain_id']);
		}
		$orgs = $orgs->to_array();

		core::js($core->data['js_function'].'('.json_encode($orgs).');');
		core::deinit();
	}

	function save_rules($require_seller_fields)
	{
		global $core;
		$rules = array(
			array('type'=>'min_length','name'=>'name','data1'=>2,'msg'=>$core->i18n['error:organizations:name']),
		);
		if($require_seller_fields)
		{
			$rules[] = array('type'=>'min_length','name'=>'profile','data1'=>2,'msg'=>$core->i18n['error:organizations:profile']);
			$rules[] = array('type'=>'min_length','name'=>'product_how','data1'=>2,'msg'=>$core->i18n['error:organizations:product_how']);
		}

		#if(!lo3::is_customer())
		#{
		#	$rules[] = array('type'=>'at_least_one_checked','name'=>'payment_allow_purchaseorder','data1'=>array('payment_allow_paypal','payment_allow_purchaseorder'),'msg'=>$core->i18n['error:organizations:one_allowed_payment']);
		#}
		return new core_ruleset('organizationsForm',$rules);
	}


	function add_new()
	{
		global $core;
		$this->add_rules()->validate();

		$org = core::model('organizations');
		$org['name'] = $core->data['name'];
		$org['orgtype_id'] = 3;
		$org['public_profile'] = 0;
		$org['allow_sell'] = $core->data['allow_sell'];

		$orgdomain = core::model('organizations_to_domains');
		if(lo3::is_admin())
		{
			$orgdomain['domain_id'] = $core->data['domain_id'];
		}
		else if(lo3::is_market())
		{
			$orgdomain['domain_id'] = $core->session['home_domain_id'];
		}
		else
		{
			# kick em out!
			lo3::require_type('admin');
		}

		$orgdomain['orgtype_id'] = 3;
		$orgdomain['is_home'] = 1;

		# set the payment options
		$domain = core::model('domains')->load($orgdomain['domain_id']);
		$org['payment_allow_paypal'] = $domain['payment_default_paypal'];
		$org['payment_allow_purchaseorder'] = $domain['payment_default_purchaseorder'];
		$org['po_due_within_days'] = $domain['po_due_within_days'];
		$org->save();

		$orgdomain['org_id'] = $org['org_id'];
		$orgdomain->save();

		$address = core::model('addresses');
		$address['org_id'] = $org['org_id'];
		$address->import_fields('address','city','region_id','postal_code','label','telephone','fax');
		$address['default_billing'] = 1;
		$address['default_shipping'] = 1;
		$address->save();
		core::js("location.href='#!organizations-edit--org_id-".$org['org_id']."';");
		core_ui::notification('organization created');
	}

	function activate()
	{
		global $core;
		if(!lo3::is_admin() && !lo3::is_market())
			lo3::require_orgtype('admin');

		$org = core::model('organizations')->load(intval($core->data['org_id']));
		$org['is_active'] = 1;
		$org->save();

		$domain = core::model('domains')->load($org['domain_id']);

		$first_user = core::model('customer_entity')
			->collection()
			->filter('org_id',$org['org_id'])
			->filter('is_enabled',1)
			->sort('entity_id')
			->limit(1);
		$first_user = $first_user->row();
		if($first_user && $first_user['email'] != '')
		{
			core::log('ready to send activation email: '.$first_user['email']);
			$email = 'emails/org_activated_';
			$email .= ($first_user['is_active'] == 1)?'verified':'not_verified';
			core::process_command($email,false,
				$first_user['email'],
				$org['domain_id'],
				$first_user,
				$domain['hostname']
			);
		}


		if($core->data['reload'] == 'no')
			core::js("$('#active_area').hide(300);");
		else
			core_datatable::js_reload('v_organizations');
		core_ui::notification('organization activated');
	}

	function deactivate()
	{
		global $core;
		if(!lo3::is_admin() && !lo3::is_market())
			lo3::require_orgtype('admin');
		core_db::query('update organizations set is_active=0 where org_id='.intval($core->data['org_id']));
		if($core->data['reload'] == 'no')
			core::js("$('#active_area').hide(300);");
		else
			core_datatable::js_reload('v_organizations');
		core_ui::notification('organization deactivated');
	}

	function enable()
	{
		global $core;
		if(!lo3::is_admin() && !lo3::is_market())
			lo3::require_orgtype('admin');
		core_db::query('update organizations set is_enabled=1 where org_id='.intval($core->data['org_id']));
		if($core->data['reload'] == 'no')
			core::js("$('#enable_area').hide(300);");
		else
			core_datatable::js_reload('v_organizations');

		core::model('events')->add_record('Org Enabled',$core->data['org_id']);
		core_ui::notification('organization enabled');
	}

	function suspend()
	{
		global $core;
		core::log('here');
		core::log('is admin: '.lo3::is_admin());
		core::log('is market: '.lo3::is_market());
		core::log('orgtype_id: '.$core->session['orgtype_id']);
		if(!lo3::is_admin() && !lo3::is_market())
			lo3::require_orgtype('admin');
		core_db::query('update organizations set is_enabled=0 where org_id='.intval($core->data['org_id']));
		if($core->data['reload'] == 'no')
			core::js("$('#enable_area').hide(300);");
		else
			core_datatable::js_reload('v_organizations');

		core::model('events')->add_record('Org Suspended',$core->data['org_id']);
		core_ui::notification('organization suspended');
	}

	function invite_user()
	{
		global $core;

		$count = core_db::col('
			select count(entity_id) as mycount
			from customer_entity
			where lower(email)=\''.trim(strtolower(mysql_escape_string($core->data['email']))).'\'
		','mycount');

		if($count > 0)
		{
			$fails = array(array('type'=>'autofail','name'=>'invite_email','msg'=>'Someone using this e-mail already has an account'));
			core::js('core.validateForm(\'organizationsForm\','.json_encode($fails).');');
			//core::js('core.validate.serverFail('.json_encode($fails).');');
			core::deinit();
		}
		else
		{
			$org = core::model('organizations')->load($core->data['org_id']);
			$url  = 'http://'.$org['hostname'].'/app.php#!registration-invite--org_id-'.$core->data['org_id'];
			$url .= '-email-'.urlencode($core->data['email']);
			$url .= '-key-'.substr(md5($core->config['registration_secret_key'] . $core->data['org_id'] . $core->data['email']),0,10);
			core::process_command('emails/registration_invite',false,$core->data['email'],$url,$org['domain_name']);
			core::model('events')->add_record('Invite Sent',$core->data['org_id'],0,$core->data['email']);
			core::js('document.organizationsForm.invite_email.value=\'\';');
			core_ui::notification('invite sent');
		}
	}

	function save()
	{
		global $core;
		$org = core::model('organizations')->load();
		list(
			$org_home_domain_id,
			$org_all_domains,
			$org_domains_by_orgtype_id
		) = core::model('customer_entity')->get_domain_permissions( $org['org_id']);

		# check to make sure they're mm
		if($org['org_id'] != $core->session['org_id'])
		{
			if(count(array_intersect($core->session['domains_by_orgtype_id'][2],$org_all_domains)) == 0)
			{
				core::log('no interset between hubs this user is MM of and org that is being updated. require admin');
				lo3::require_orgtype('admin');
			}
		}

		core::dump_data();

		# figure out which fields to import, based on role
		if(lo3::is_admin())
			$org->import_fields('org_id','name','domain_id','allow_sell','payment_allow_paypal','payment_allow_purchaseorder','payment_allow_ach','buyer_type','profile','product_how','public_profile','facebook','twitter', 'social_option_id', 'payment_entity_id', 'po_due_within_days');
		else if(lo3::is_market())
			$org->import_fields('org_id','name','allow_sell','profile','payment_allow_paypal','payment_allow_purchaseorder','payment_allow_ach','product_how','public_profile','facebook','twitter', 'social_option_id', 'payment_entity_id', 'po_due_within_days');
		else
			$org->import_fields('org_id','name','profile','product_how','public_profile','facebook','twitter', 'social_option_id', 'payment_entity_id');

		# save the data, and reload
		$org->save();
		$data = core::model('organizations')->load();

		if(
			$org['allow_sell'] == 1 and
			(
				!lo3::is_customer() ||
				(lo3::is_customer() && $org['feature_sellers_cannot_manage_cross_sells'] == 0)
			)
		)
		{
			# figure out the new organization_cross_sells
			core_db::query('delete from organization_cross_sells where org_id='.$org['org_id']);
			$domains = core::model('domains')
				->collection()
				->filter(
					'domain_id',
					'in',
					'(
						select domain_id
						from domain_cross_sells
						where accept_from_domain_id in ('.implode(',',$org_all_domains).')
					)');
			foreach($domains as $domain)
			{
				if($core->data['sell_on_'.$domain['domain_id']] == 1)
				{
					$ocs = core::model('organization_cross_sells');
					$ocs['org_id'] = $org['org_id'];
					$ocs['sell_on_domain_id'] = $domain['domain_id'];
					$ocs->save();
				}
			}
			$ocs = core::model('organization_cross_sells');
			$ocs['org_id'] = $org['org_id'];
			$ocs['sell_on_domain_id'] = $org['domain_id'];
			$ocs->save();

			# figure out the new delivery days
			core::log(print_r($core->data,true));
			core_db::query('delete from organization_delivery_cross_sells where org_id='.$org['org_id']);
			$dds = core::model('delivery_days')->collection();
			foreach($dds as $ods_item)
			{
				if($core->data['deliver_on_'.$ods_item['dd_id']] == 1)
				{
					$ods = core::model('organization_delivery_cross_sells');
					$ods['org_id'] = $org['org_id'];
					$ods['dd_id'] = $ods_item['dd_id'];
					$ods->save();
				}
			}
		}

		//~ core::log('cond 1: '.lo3::is_admin());
		//~ core::log('cond 2: '.(count($org_domains_by_orgtype_id[3]) > 0));
		//~ core::log('cond 3: '.(!in_array($core->data['domain_id'],$org_domains_by_orgtype_id[3])));
		//~ core::log('current org domains: '.print_r($org_domains_by_orgtype_id[3],true));
		//~ core::log('new domain: '.$core->data['domain_id']);
		# check for a hub change
		if(lo3::is_admin() && count($org_domains_by_orgtype_id[3]) > 0 && !in_array($core->data['domain_id'],$org_domains_by_orgtype_id[3]))
		{
			core::log('changing hub');
			core_db::query('delete from organizations_to_domains where org_id='.$org['org_id']);
			core_db::query('insert into organizations_to_domains (domain_id,org_id,orgtype_id,is_home) values ('.intval($core->data['domain_id']).','.$org['org_id'].',3,1)');
		}



		core_ui::notification($core->i18n('messages:generic_saved','organization'),false,($core->data['do_redirect'] != 1));
		if($core->data['do_redirect'] == 1)
			core::redirect('organizations','list');
	}

	function save_address()
	{
		global $core;

		$address = core::model('addresses')->import_fields('address_id','label','org_id','address','city','region_id','postal_code','telephone','fax','default_billing','delivery_instructions','latitude','longitude')->save();

		core_datatable::js_reload('addresses');
		core_datatable::js_reload('organizations');
		core::js('core.addresses['.$address['address_id'].']=['.$address->to_json().'];');

			core_ui::notification('address saved');
	}

	function delete_addresses()
	{
		global $core;
		core_db::query('update addresses set is_deleted=1 where address_id in ('.$core->data['address_ids'].');');
		core_db::query('update products set addr_id=0 where addr_id in ('.$core->data['address_ids'].');');
		core_datatable::js_reload('addresses');

		core_ui::notification('addresses deleted');
	}

	function change_billing_address()
	{
		global $core;

		core::log('changing billing address for '.$core->data['org_id'].' to '.$core->data['address_id']);
		core_db::query('update addresses set default_billing=0 where org_id='.intval($core->data['org_id']));
		core_db::query('update addresses set default_billing=1 where address_id='.intval($core->data['address_id']));

		core::deinit();
	}

	function change_shipping_address()
	{
		global $core;

		core::log('changing default_shipping address for '.$core->data['org_id'].' to '.$core->data['address_id']);
		core_db::query('update addresses set default_shipping=0 where org_id='.intval($core->data['org_id']));
		core_db::query('update addresses set default_shipping=1 where address_id='.intval($core->data['address_id']));

		core::deinit();
	}

	function save_image()
	{
		global $core;
		core::load_library('image');

		core::log('prod_id: '.$core->data['prod_id'].'<br />');
		core::log(print_r($_FILES,true));
		$new = new core_image($_FILES['new_image']);
		$new->load_image();

		core::log('image saved: '.$new->extension);

		//~ if($new->width > 400 || $new->height> 300)
		//~ {
			//~ exit('<html><body style="color: #fff;background-color:#fff;overflow:hidden;">toolarge:done</body></html>');
		//~ }
		#
		$filepath = $core->paths['base'].'/../img/organizations/'.$data['org_id'].'.';
		if(file_exists($filepath.'png'))
			unlink($filepath.'png');
		if(file_exists($filepath.'jpg'))
			unlink($filepath.'jpg');
		if(file_exists($filepath.'gif'))
			unlink($filepath.'gif');

		move_uploaded_file($new->path,$core->paths['base'].'/../img/organizations/'.$core->data['org_id'].'.'.$new->extension);
		core::log('rm '.$core->paths['base'].'/../img/organizations/cached/'.$core->data['org_id'].'.*.jpg;');
		shell_exec('rm '.$core->paths['base'].'/../img/organizations/cached/'.$core->data['org_id'].'.*.jpg;');

		exit('<html><body style="color: #fff;background-color:#fff;overflow:hidden;">'.$new->extension.':done</body></html>');
	}

	function remove_image()
	{
		global $core;
		core::load_library('image');

		$filepath = $core->paths['base'].'/../img/organizations/'.$core->data['org_id'].'.';
		if(file_exists($filepath.'png'))
		{
			unlink($filepath.'png');
			shell_exec('rm '.$filepath.'cache/'.intval($core->data['org_id']).'.*.png');
		}
		if(file_exists($filepath.'jpg'))
		{
			unlink($filepath.'jpg');
			shell_exec('rm '.$filepath.'cache/'.intval($core->data['org_id']).'.*.jpg');
		}
		if(file_exists($filepath.'gif'))
		{
			unlink($filepath.'gif');
			shell_exec('rm '.$filepath.'cache/'.intval($core->data['org_id']).'.*.gif');
		}

		core::js("$('#orgImg').fadeOut();");
	}


	function delete_org()
	{
		global $core;
		lo3::require_orgtype('market');
		$org = core::model('organizations')->load(intval($core->data['org_id']));
		$org['is_deleted'] = 1;
		$org->save();

		#core_db::query('update products set is_deleted=='.intval($core->data['prod_id']).' and product_id>0;');
		#core_db::query('delete from discount_codes where restrict_to_product_id='.intval($core->data['prod_id']).' and restrict_to_product_id>0;');

		core_datatable::js_reload('v_organizations');
		core_ui::notification('organization deleted');
	}

	function delete_user()
	{
		global $core;
		$user = core::model('customer_entity')->load(intval($core->data['user_id']));
		$org = core::model('organizations')->load(intval($user['org_id']));

		# if this is NOT a user deleting another user in their org
		if($user['org_id'] != $core->session['org_id'])
		{
			list(
				$home_domain_id,
				$all_domains,
				$domains_by_orgtype_id
			) = core::model('customer_entity')->get_domain_permissions( $user['org_id']);
			if(0 == count(array_intersect($all_domains,$core->session['domains_by_orgtype_id'][2])))
			{
				lo3::require_orgtype('admin');
			}
		}
		$user['is_deleted'] = 1;
		$user->save();

		#core_db::query('update products set is_deleted=='.intval($core->data['prod_id']).' and product_id>0;');
		#core_db::query('delete from discount_codes where restrict_to_product_id='.intval($core->data['prod_id']).' and restrict_to_product_id>0;');

		core_datatable::js_reload('customer_entity');
		core_datatable::js_reload('org_users');
		core_ui::notification('user deleted');
	}
}

?>