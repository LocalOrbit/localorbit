<?php

class lo3
{
	public static function require_login()
	{
		global $core;
		if(intval($core->session['user_id']) == 0)
		{
			$core->config['postauth_url'] = $core->data['_requestor_url'];
			core::process_command('auth/form');
			core::deinit();
		}
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
			core::process_command('auth/form');
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
			core::process_command('auth/form');
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
	
	public static function is_seller()
	{
		global $core;
		return ($core->session['allow_sell'] == 1);
	}
}

?>