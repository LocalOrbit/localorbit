<?php

class core_controller_market extends core_controller
{
	function make_new()
	{
		global $core;
	}

	function save_lat_long()
	{
		global $core;
		core::model('addresses')->import_fields('address_id','latitude','longitude')->save();
		core::deinit();
	}

	function rules()
	{
		global $core;
		return new core_ruleset('marketForm',array(
			array('type'=>'min_length','name'=>'name','data1'=>2,'msg'=>$core->i18n['error:markets:name']),
			#array('type'=>'at_least_one_checked','name'=>'payment_default_purchaseorder','data1'=>array('payment_default_paypal','payment_default_purchaseorder'),'msg'=>$core->i18n['error:markets:one_default_payment']),
		));
	}

	function save()
	{
		global $core;

		//$branding = core::model('domains_branding')->collection()->filter('domain_id', intval($core->data['domain_id']))->row();

		core::model('domains_branding')->delete_all($core->data['domain_id']);
		$branding = core::model('domains_branding')->get_branding($core->data);

		$market = core::model('domains');
		$market->load($core->data['domain_id']);

		# changes to the is_live property need to be logged using the
		# domains_is_live_history table
		if($market['is_live'] != $core->data['is_live'])
		{
			# if the market is live, then update the current
			# row in domains_is_live_history to set the end_is_live = now
			core::log('flag is diff!!!');
			if($market['is_live'] == 1)
			{
				core_db::query('
					update domains_is_live_history
					set is_live_end=CURRENT_TIMESTAMP,is_current=0
					where is_current=1 and domain_id='.intval($core->data['domain_id'])
				);
			}
			else
			{
				$obj = core::model('domains_is_live_history');
				$obj['domain_id'] = $core->data['domain_id'];
				$obj->save();
			}
		}

		if(lo3::is_admin())
		{
			core::log(print_r($core->data, true));
			$core->data['service_fee'] = core_format::parse_price($core->data['service_fee']);
			$core->data['hostname'] = strtolower($core->data['hostname']);
			$core->data['seller_payer']   = core_ui::radio_value('seller_payer',  array('lo','hub'));
			$core->data['buyer_invoicer'] = core_ui::radio_value('buyer_invoicer',array('lo','hub'));
			
			
			core::log('seller payer value: '.$core->data['seller_payer']);
			core::log('buyer_invoicer  value: '.$core->data['buyer_invoicer']);
			#core::deinit();

			$market->import_fields(
				'domain_id','name',
				'hostname','tz_id','do_daylight_savings',
				'is_live','is_closed','show_on_homepage','po_due_within_days','seller_payer','buyer_invoicer',
				'order_minimum','fee_percen_lo','fee_percen_hub','paypal_processing_fee','hub_covers_fees','autoactivate_organization',
				'secondary_contact_name','secondary_contact_email','secondary_contact_phone',
				'payment_allow_authorize','payment_allow_paypal','payment_allow_purchaseorder','payment_allow_ach',
				'payment_default_paypal','payment_default_purchaseorder','payment_default_ach',
				'lo_managed','custom_zendesk','market_policies','market_profile',
				'custom_tagline','dashboard_note','closed_note','buyer_types_description','bubble_offset',
				'feature_require_seller_all_delivery_opts','feature_force_items_to_soonest_delivery',
				'feature_sellers_enter_price_without_fees','feature_sellers_cannot_manage_cross_sells',
				'feature_sellers_mark_items_delivered','feature_allow_anonymous_shopping',
				'default_homepage','seller_payment_managed_by','payable_org_id','payables_create_on',
				'service_fee','sfs_id','opm_id','facebook','twitter', 'social_option_id'
			);
		}
		else if(lo3::is_market())
		{
			$market->import_fields(
				'domain_id','name',
				'tz_id','do_daylight_savings',
				'is_closed','show_on_homepage','payment_default_paypal','payment_default_purchaseorder',
				'secondary_contact_name','secondary_contact_email','secondary_contact_phone',
				'lo_managed','custom_zendesk','custom_tagline','dashboard_note','market_policies',
				'market_profile','closed_note','buyer_types_description','bubble_offset','facebook','twitter', 'social_option_id'
			);
		}
		else
		{
			lo3::require_orgtype('admin');
		}

		$branding->save();
		$market->save();

		core::js('market.reloadCss();market.setDefaults("'.
			core_format::get_hex_code($branding['background_color']) . '",' .
			($branding['background_id'] ? $branding['background_id'] : 'null') . ',"' .
			core_format::get_hex_code($branding['text_color']) . '",' .
			$branding['header_font'] . ');');

		if(lo3::is_admin())
		{
			$domains = core::model('domains')->collection();
			$cross_sells = core::model('domain_cross_sells')->collection()->filter('domain_id',$data['domain_id']);
			core_db::query('delete from domain_cross_sells where domain_id='.$market['domain_id']);
			foreach($domains as $domain)
			{
				if($core->data['accept_products_from_'.$domain['domain_id']] == 1)
				{
					$cs = core::model('domain_cross_sells');
					$cs['domain_id'] = $market['domain_id'];
					$cs['accept_from_domain_id'] = $domain['domain_id'];
					$cs->save();
				}
			}
		}

		if($core->config['domain']['domain_id'] == $core->data['domain_id'])
		{
			$core->config['domain'] = $market;
			core::process_command('whitelabel/get_options');
		}
		core_ui::notification($core->i18n('messages:generic_saved','Market'),false,($core->data['do_redirect'] != 1));
		if($core->data['do_redirect'] == 1)
			core::redirect('market','list');

	}

	function save_logo1()
	{
		global $core;
		core::load_library('image');
		define('__CORE_ERROR_OUTPUT__','exit');

		#echo('prod_id: '.$core->data['prod_id'].'<br />');
		$new = new core_image($_FILES['logo_image']);
		$new->load_image();

		# check the sizes
		if($new->width <= 400 && $new->height <= 400)
		{
			# make the hub override directory if we need to
			if(!is_dir($core->paths['base'].'/../img/'.$core->data['domain_id']))
				mkdir($core->paths['base'].'/../img/'.$core->data['domain_id']);

			# move the new file
			move_uploaded_file($new->path,$core->paths['base'].'/../img/'.$core->data['domain_id'].'/logo-large.'.$new->extension);
			echo('<html><body style="color: #fff;background-color:#fff;overflow:hidden;">'.$new->extension.':done</body></html>');
			core::deinit(false);
		}
		else
		{
			exit('<html><body style="color: #fff;background-color:#fff;overflow:hidden;">toolarge:done</body></html>');
		}
	}

	function remove_logo1()
	{
		global $core;
		remove_image('logo-large',$core->data['domain_id']);
		core::js("$('#removeLogo1').fadeOut('fast');");
		core::js('document.getElementById(\'logo1\').setAttribute(\'src\',\''.image('logo-large',$core->data['domain_id']).'\');');
		core::deinit();
	}


	function save_logo2()
	{
		global $core;
		core::load_library('image');
		define('__CORE_ERROR_OUTPUT__','exit');

		#echo('prod_id: '.$core->data['prod_id'].'<br />');
		$new = new core_image($_FILES['email_image']);
		$new->load_image();

		# check the sizes
		if($new->width <= 100 && $new->height <= 100)
		{
			# make the hub override directory if we need to
			if(!is_dir($core->paths['base'].'/../img/'.$core->data['domain_id']))
				mkdir($core->paths['base'].'/../img/'.$core->data['domain_id']);

			# move the new file
			move_uploaded_file($new->path,$core->paths['base'].'/../img/'.$core->data['domain_id'].'/logo-email.'.$new->extension);
			echo('<html><body style="color: #fff;background-color:#fff;overflow:hidden;">'.$new->extension.':done</body></html>');
			core::deinit(false);
		}
		else
		{
			exit('<html><body style="color: #fff;background-color:#fff;overflow:hidden;">toolarge:done</body></html>');
		}
	}

	function remove_logo2()
	{
		global $core;
		remove_image('logo-email',$core->data['domain_id']);
		core::js("$('#removeLogo2').fadeOut('fast');");
		core::js('document.getElementById(\'logo2\').setAttribute(\'src\',\''.image('logo-email',$core->data['domain_id']).'\');');
		core::deinit();
	}

	function save_logo3()
	{
		global $core;
		core::load_library('image');
		define('__CORE_ERROR_OUTPUT__','exit');

		#echo('prod_id: '.$core->data['prod_id'].'<br />');
		$new = new core_image($_FILES['profile']);
		$new->load_image();

		# check the sizes
		if($new->width <= 600 && $new->height <= 500)
		{
			# make the hub override directory if we need to
			if(!is_dir($core->paths['base'].'/../img/'.$core->data['domain_id']))
				mkdir($core->paths['base'].'/../img/'.$core->data['domain_id']);

			# move the new file
			move_uploaded_file($new->path,$core->paths['base'].'/../img/'.$core->data['domain_id'].'/profile.'.$new->extension);
			echo('<html><body style="color: #fff;background-color:#fff;overflow:hidden;">'.$new->extension.':done</body></html>');
			core::deinit(false);
		}
		else
		{
			exit('<html><body style="color: #fff;background-color:#fff;overflow:hidden;">toolarge:done</body></html>');
		}
	}


	function remove_logo3()
	{
		global $core;
		remove_image('profile',$core->data['domain_id']);
		core::js("$('#removeLogo3').fadeOut('fast');");
		core::js('document.getElementById(\'logo3\').setAttribute(\'src\',\''.image('profile',$core->data['domain_id']).'\');');
		core::deinit();
	}


	function save_address()
	{
		global $core;
		core::log('here');
		$address = core::model('addresses')->import_fields('address_id','label','org_id','address','city','region_id','postal_code','telephone','fax','latitude','longitude');
		$address->save();
		core::log('saved');
		core_datatable::js_reload('addresses');
		core_datatable::js_reload('delivery_days');
		core::js('core.addresses['.$address['address_id'].']=['.$address->to_json().'];');

		$all_addrs = array('Direct to customer'=>'0');
		$addrs = core::model('addresses')->collection()->filter('org_id','=',$address['org_id'])->filter('is_deleted','=',0)->sort('label');
		foreach($addrs as $addr)
		{
			$all_addrs[$addr['label']] = $addr['address_id'];
		}
		core_ui::update_select('pickup_address_id',$all_addrs);
		core_ui::update_select('deliv_address_id',$all_addrs);


		core_ui::notification('address saved');
	}

	function delete_addresses()
	{
		global $core;
		core_db::query('update addresses set is_deleted=1 where address_id in ('.$core->data['address_ids'].');');
		core_datatable::js_reload('addresses');

		core_ui::notification('addresses deleted');
	}


	function save_delivery()
	{
		global $core;

		if($core->data['deliv_address_id'] == 0)
		{
			$core->data['pickup_address_id'] = 0;
		}
		$dd = core::model('delivery_days')->import_fields('dd_id','hours_due_before','domain_id','cycle','day_ordinal','day_nbr','deliv_address_id','delivery_start_time','delivery_end_time','pickup_start_time','pickup_end_time','pickup_address_id')->save();

		$delivery_fee = core::model('delivery_fees')->import_fields('devfee_id', 'dd_id', 'fee_calc_type_id', 'amount');
		$delivery_fee['fee_type'] = 'delivery';
		$delivery_fee['dd_id'] = $dd['dd_id'];
		$delivery_fee->save();

		core::log(print_r($core->data,true));

		# if all products insert rows into product_delivery_cross_sells
		if ($core->data['allproducts']) {
			core::log('adding all products');
			core_db::query('insert into product_delivery_cross_sells (prod_id, dd_id) select prod_id,'. $dd['dd_id'] . ' from products
			left join organizations on products.org_id = organizations.org_id
			left join organizations_to_domains on organizations.org_id = organizations_to_domains.org_id and is_home = 1
			where domain_id = '.$dd['domain_id']);
		}
		# if all cross products insert rows into product_delivery_cross_sells
		if ($core->data['allcrosssellproducts']) {
			core::log('adding all cross sell products');
			core_db::query('insert into product_delivery_cross_sells (prod_id, dd_id) select distinct products.prod_id,' . $dd['dd_id'] . ' from products
			left join organizations on products.org_id = organizations.org_id
			left join organizations_to_domains on organizations.org_id = organizations_to_domains.org_id and is_home = 1
			left join domain_cross_sells on domain_cross_sells.accept_from_domain_id  = organizations_to_domains.domain_id
			inner join product_delivery_cross_sells on products.prod_id = product_delivery_cross_sells.prod_id
         where domain_cross_sells.domain_id = '. $dd['domain_id']);

         core_db::query('insert into organization_delivery_cross_sells (org_id, dd_id) select distinct organizations.org_id,' . $dd['dd_id'] .' from organizations
         left join organization_cross_sells
         on organizations.org_id = organization_cross_sells.org_id
         left join products
         on organizations.org_id = products.org_id
         inner join product_delivery_cross_sells
         on products.prod_id = product_delivery_cross_sells.prod_id
         left join organizations_to_domains
         on organizations.org_id = organizations_to_domains.org_id and is_home = 1
         left join domain_cross_sells
         on domain_cross_sells.accept_from_domain_id  = organizations_to_domains.domain_id
         and organization_cross_sells.sell_on_domain_id = domain_cross_sells.domain_id
         where domain_cross_sells.domain_id = '. $dd['domain_id']);
		}
		core_datatable::js_reload('delivery_days');
		#core::log('pickup_address_id is: '.$dd['pickup_address_id']);
		#core::log('heres whats in ->__data: '.print_r($dd->__data,true));
		#core::log('core.delivery_days['.$dd['dd_id'].']=['.$dd->to_json().'];');
		#core::js('core.delivery_days['.$dd['dd_id'].']=['.$dd->to_json().'];');
		core_ui::notification('delivery day saved');
	}

	function delete_deliveries()
	{
		global $core;
      core_db::query('delete from delivery_days where dd_id in ('.$core->data['dd_ids'].');');
      core_db::query('delete from delivery_fees where dd_id in ('.$core->data['dd_ids'].');');
		core_datatable::js_reload('delivery_days');
		core_ui::notification('delivery_days deleted');
	}

	function save_temp_style()
	{
		global $core;
		core::model('domains_branding')->save_temp($core->data);
		core::js('market.previewStyle();');
	}
}

?>