<?php

class lo3
{
	public static function is_logged_in()
	{
		global $core;
		if (intval($core->session['user_id']) > 0) {
			return true;
		} else {
			return false;
		}
	}
	
	public static function require_login()
	{
		global $core;
		if(intval($core->session['user_id']) == 0)
		{
			$core->session['postauth_url'] = $core->data['_requestor_url'];

			//core.ui.popup('','','<strong>Error:</strong><br />Please correct this error and try again.','close');
			core::js("location.href='/login.php?login_req=1';");
			core::deinit();
		}
	}

	public static function confirm_account_authenticated()
	{
		global $core;
		
		if (lo3::is_logged_in()) {
			if($core->session['is_active'] == 0) {
				//core::process_command('catalog/not_emailconfirm',false);
				core::process_command('catalog/not_emailconfirm',false);
				core::js("location.href='/app.php#!catalog-not_emailconfirm';");
				core::deinit();
			} else if ($core->session['org_is_active'] == 0) {
				//core::process_command('catalog/not_activated',false);
				core::js("location.href='/app.php#!catalog-not_activated';");
				core::deinit();
			}
		}
	}
	
	public static function user_can_shop()
	{
		global $core;	
		// store closed
		//http://devnorthsoundwa.localorb.it/app.php#!catalog-shop--cat1-121
		
		if($core->config['domain']['is_closed'] == 1) {
			//core::process_command('catalog/store_closed',false);
			core::js("location.href='/app.php#!catalog-store_closed';");
			core::deinit();
		}
		
		if($core->config['domain']['feature_allow_anonymous_shopping'] != 1) {
			lo3::require_login();
		}
		
		lo3::confirm_account_authenticated();
	}
	
	
	
	public static function require_orgtype($orgtype)
	{
		global $core;
		
		if(count($core->session['domains_by_orgtype_id'][1]) > 0)
			return;
			
		$types = array(
			'admin'=>1,
			'market'=>2,
			'customer'=>3,
		);
		
		if(!is_array($core->session['domains_by_orgtype_id'][$types[$orgtype]]))
			$core->session['domains_by_orgtype_id'][$types[$orgtype]] = array();
		
		if(!in_array($core->config['domain']['domain_id'],$core->session['domains_by_orgtype_id'][$types[$orgtype]]))
		{
			$core->config['postauth_url'] = $core->data['_requestor_url'];
			core::js("location.href='/login.php';");
			core::deinit();
		}
	}
	
	public static function require_seller()
	{
		global $core;

		if($core->session['orgtype_id'] == 1)
			return;

		if(intval($core->session['allow_sell']) == 0)
		{
			$core->config['postauth_url'] = $core->data['_requestor_url'];
			core::js("location.href='/login.php';");
			core::deinit();
		}
	}
	
	public static function require_permission($name='')
	{
	}
	
	public static function has_permission($name='')
	{
		return true;
	}
	
	public static function is_admin()
	{
		global $core;
		
		if(!is_array($core->session['domains_by_orgtype_id'][1]))
			$core->session['domains_by_orgtype_id'][1] = array();
			
		return (count($core->session['domains_by_orgtype_id'][1]) > 0);
	}
	
	public static function is_market()
	{
		global $core;

		if(!is_array($core->session['domains_by_orgtype_id'][2]))
			$core->session['domains_by_orgtype_id'][2] = array();

		return (in_array($core->config['domain']['domain_id'],$core->session['domains_by_orgtype_id'][2]));
	}
	
	public static function is_customer()
	{
		global $core;

		if(!is_array($core->session['domains_by_orgtype_id'][3]))
			$core->session['domains_by_orgtype_id'][3] = array();

		return (in_array($core->config['domain']['domain_id'],$core->session['domains_by_orgtype_id'][3]));
	}
	
	public static function is_cross_seller()
	{
		global $core;
		$count = core_db::col('
			select count(sell_on_domain_id) as mycount from organization_cross_sells where org_id='.$core->session['org_id'],'mycount');
		return ($count > 0);		
	}

	public static function is_self_managed()
	{
		global $core;
		return (lo3::is_market() and $core->config['domain']['seller_payer'] == 'hub');
	}
	public static function is_fully_managed()
	{
		global $core;
		return (lo3::is_market() and $core->config['domain']['seller_payer'] != 'hub');
	}
	
	public static function is_self_managed_customer()
	{
		global $core;
		return (lo3::is_customer() and $core->config['domain']['seller_payer'] == 'hub');
	}
	public static function is_fully_managed_customer()
	{
		global $core;
		return (lo3::is_customer() and $core->config['domain']['seller_payer'] != 'hub');
	}
	
	
	public static function is_seller()
	{
		global $core;
		return ($core->session['allow_sell'] == 1);
	}
	
	public static function is_buyer()
	{
		return (!lo3::is_admin() && !lo3::is_market() && !lo3::is_seller());
	}
	
	public static function is_org_payment_purchase_order_allowed()
	{
		global $core;
		return ($core->session['org_payment_allow_purchaseorder'] == 1);
	}
	
	public static function is_org_payment_paypal_allowed()
	{
		global $core;
		return ($core->session['org_payment_allow_paypal'] == 1);
	}
	
	public static function is_org_payment_ach_allowed()
	{
		global $core;
		return ($core->session['org_payment_allow_ach'] == 1);
	}
	
	public static function does_org_have_purchase_order_history()
	{
		global $core;
		return ($core->session['org_purchase_order_count'] > 0);
	}
}

?>