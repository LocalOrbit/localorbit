<?php 

class core_controller_users extends core_controller
{
	function save_new()
	{
		global $core;
		
		$core->dump_data();
		# perform some validation
		$this->add_rules()->validate('userAddForm');
		core::process_command('registration/check_unique',false,'userAddForm');
		
		# encrypt their password
		core::load_library('crypto');
		$core->data['password'] = core_crypto::encode_password($core->data['password']);
		
		$user = core::model('customer_entity');
		$user['created_at'] = $core->config['time'];
		$user->import_fields('org_id','first_name','last_name','email','password')->save();
		
		# redirect
		core::js("location.href='#!users-edit--entity_id-".$user['entity_id']."';");
		core_ui::notification('user created');
	}
	
	function add_rules()
	{
		global $core;
		return new core_ruleset('userAddForm',array(
			array('type'=>'selected','name'=>'org_id','msg'=>$core->i18n['error:customer:org_id']),
			array('type'=>'min_length','name'=>'first_name','data1'=>2,'msg'=>$core->i18n['error:customer:firstname']),
			array('type'=>'min_length','name'=>'last_name','data1'=>2,'msg'=>$core->i18n['error:customer:lastname']),
			array('type'=>'valid_email','name'=>'email','msg'=>$core->i18n['error:customer:email']),
			array('type'=>'min_length','name'=>'password','data1'=>8,'msg'=>$core->i18n['error:customer:password']),
			array('type'=>'match_confirm_field','name'=>'password','data1'=>'password_confirm','msg'=>$core->i18n['error:customer:password-match']),
		));
	}
	
	function edit_rules()
	{
		global $core;
		return new core_ruleset('userForm',array(
			array('type'=>'min_length','name'=>'first_name','data1'=>2,'msg'=>$core->i18n['error:customer:firstname']),
			array('type'=>'min_length','name'=>'last_name','data1'=>2,'msg'=>$core->i18n['error:customer:lastname']),
			array('type'=>'valid_email','name'=>'email','msg'=>$core->i18n['error:customer:email']),
			array('type'=>'min_length','name'=>'password','data1'=>8,'data2'=>'yes','msg'=>$core->i18n['error:customer:password']),
			array('type'=>'match_confirm_field','name'=>'password','data1'=>'confirm_password','msg'=>$core->i18n['error:customer:password-match']),
		));
	}
	
	function do_change_password()
	{
		global $core;
		core::load_library('crypto');
		
		if(is_null($do_notify))	$do_notify=true;
		$user = core::model('customer_entity')->load($core->session['user_id']);
		
		
		$user['password'] = core_crypto::encode_password($core->data['password']);
		$user->save();
		
		# handle a password update
		$core->data['password'] = trim($core->data['password']);
		$core->data['confirm_password'] = trim($core->data['confirm_password']);
		if(isset($core->data['password']) && $core->data['password'] !='' && $core->data['password'] == $core->data['confirm_password'])
		{
			core::load_library('crypto');
			$user['password'] = core_crypto::encode_password($core->data['password']);
			if($user['entity_id'] != $core->session['user_id'])
			{	
				core::process_command('emails/reset_password',false,
					$user['email'],
					$core->data['password'],
					$org['domain_id']
				);
			}
		}
		core_ui::notification('password changed');
		
	}
	
	function delete()
	{
		#We need to think about if we really want to do this or just not display  some people
		# global $core;
		# core::log('trying to delete');
		# core::model('customer_entity')->delete($core->data['entity_id']);
		# core_datatable::js_reload('customer_entity');
		# core_ui::notification('user deleted');
	}
	
	function enable()
	{
		global $core;
		if(!lo3::is_admin() && !lo3::is_market())
		{
			$user = core::model('customer_entity')->load(intval($core->data['entity_id']));
			if($core->session['org_id'] != $user['org_id'])
				lo3::require_orgtype('admin');
		}
		core_db::query('update customer_entity set is_enabled=1 where entity_id='.intval($core->data['entity_id']));
		core_datatable::js_reload($core->data['table']);
		core::model('events')->add_record('User Activated',$core->data['entity_id']);		
		core_ui::notification('user enabled');
	}
	
	function suspend()
	{
		global $core;
		
		if($core->data['entity_id'] == $core->session['user_id'])
		{
			core_ui::notification('You cannot suspend yourself.');
		}
		else
		{
			if(!lo3::is_admin() && !lo3::is_market())
			{
				$user = core::model('customer_entity')->load(intval($core->data['entity_id']));
				if($core->session['org_id'] != $user['org_id'])
					lo3::require_orgtype('admin');
			}
			core_db::query('update customer_entity set is_enabled=0 where entity_id='.intval($core->data['entity_id']));
			core_datatable::js_reload($core->data['table']);
			core::model('events')->add_record('User Deactivated',$core->data['entity_id']);		
			core_ui::notification('user suspended');
		}
	}
	
	function save()
	{
		global $core;
		
		$core->dump_data();
		# basic field save
		$this->edit_rules()->validate('userForm');
		core::process_command('registration/check_unique',false,'userForm',$core->data['entity_id']);
		
		$user = core::model('customer_entity')->load($core->data['entity_id']);
		$org = core::model('organizations')->load($user['org_id']);
			
		# if not trying to save the current user, check rules for MMss and admins
		if($user['entity_id'] != $core->session['user_id'])
		{
			if(!in_array($org['domain_id'], $core->session['domains_by_orgtype_id'][2]))
			{
				lo3::require_orgtype('admin');
			}
		}
		
		# this would imply an email change is being done
		if($core->data['email'] != $user['email'])
		{
			core::process_command('emails/email_change',false,
				$user['email'],
				$core->data['email'],
				$user['first_name'],
				$org['domain_id']
			);
		}
		
		$user->import_fields('entity_id','first_name','last_name','email');

		# handle a password update
		$core->data['password'] = trim($core->data['password']);
		$core->data['confirm_password'] = trim($core->data['confirm_password']);
		if(isset($core->data['password']) && $core->data['password'] !='' && $core->data['password'] == $core->data['confirm_password'])
		{
			core::load_library('crypto');
			$user['password'] = core_crypto::encode_password($core->data['password']);
			if($user['entity_id'] != $core->session['user_id'])
			{	
				core::process_command('emails/reset_password',false,
					$user['email'],
					$core->data['password'],
					$org['domain_id']
				);
			}
		}
		
		$user->save();
		
		if($user['entity_id'] == $core->session['user_id'])
		{
			$core->session['first_name'] = $core->data['first_name'];
			$core->session['last_name'] = $core->data['last_name'];
			$core->session['email'] = $core->data['email'];
			core::js("$('h1').html('Editing ".addslashes($core->data['first_name'])." ".addslashes($core->data['last_name'])."');");
		}
		
		core_ui::notification($core->i18n('messages:generic_saved','user'),false,($core->data['do_redirect'] != 1));
		if($core->data['do_redirect'] == 1)
			core::redirect('users','list');
	}
}

?>
