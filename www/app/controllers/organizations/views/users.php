<div class="tabarea" id="orgtabs-a3">
	<?php 
	global $data,$org_all_domains;
	
	
	if(!isset($data['org_id']))
		$data = array('org_id'=>$core->data['org_id']);

	# if this org isn't the same as the current user's org, then apply permissions
	if($data['org_id'] != $core->session['org_id'])
	{
		# if this org's list of domains does NOT 
		# intersect the list of domains that the current 
		# user is a MM of, then they HAVE to be an admin to manage them
		if(count(array_intersect($org_all_domains,$core->session['domains_by_orgtype_id'][2])) == 0)
		{
			core::log('mm intersect attempt try');
			lo3::require_orgtype('admin');
			core::log('mm intersect attempt success');
		}
		else
		{
			core::log('requiring market');
			lo3::require_orgtype('market');
		}
	}


	
	$col = core::model('customer_entity')->collection();
	$col->add_formatter('enable_suspend_links');
	$col->filter('org_id',$data['org_id']);	
	$col->filter('is_deleted','=',0);	
	$users = new core_datatable('org_users','organizations/users?org_id='.$core->data['org_id'],$col);
	#$users->add_filter(new core_datatable_filter('org_id'));
	$users->add(new core_datacolumn('first_name','Name',true,'30%','<a href="#!users-edit--entity_id-{entity_id}"><b>{first_name} {last_name}</b>'));
	$users->add(new core_datacolumn('email','E-mail',true,'40%','<a href="mailTo:{email}">{email}</a>'));
	$users->add(new core_datacolumn('created_at','Registered On',true,'17%','<a href="#!users-edit--entity_id-{entity_id}">{created_at}</a>'));
	
	# They are an admin or a MM in their home hub so let them login as users
	$actions = '';
	if(lo3::is_market() ||  lo3::is_admin())
	{
		$actions = '<a href="#!auth-loginas--entity_id-{entity_id}">Login &raquo;</a><br /><a href="javascript:core.doRequest(\'/users/{enable_action}\',{\'entity_id\':{entity_id},\'table\':\'org_users\'});">{enable_action} &raquo;</a>';
	}
	else
	{
		$actions = '<a href="javascript:core.doRequest(\'/users/{enable_action}\',{\'entity_id\':{entity_id},\'table\':\'org_users\'});">{enable_action} &raquo;</a>';
	}
	$actions .= '<a href="#!organizations-edit--org_id-{org_id}" onclick="org.deleteUser({entity_id},this,'.$core->session['user_id'].');">Delete&nbsp;&raquo;</a>';
	$users->add(new core_datacolumn('entity_id','&nbsp;',false,'13%',$actions,' ',' '));

	$users->columns[2]->autoformat='date-short';
	$users->display_filter_resizer = false;
	$users->display_exporter_pager = false;
	$users->size = (-1);
	$users->render();
	?>
	<br />
	<input type="text" name="invite_email" value="" />
	<input type="button" class="button_secondary" value="invite user" onclick="org.inviteUser(<?=$data['domain_id']?>);" />
	<?if($core->config['stage'] != 'production'){?>
	<input type="button" class="button_secondary" value="Testing/qa only" onclick="document.organizationsForm.invite_email.value='localorbit.testing+'+(new String((Math.floor(Math.random() * 1000))))+'@gmail.com';org.inviteUser(<?=$data['domain_id']?>);" />
	<?}?>
</div>