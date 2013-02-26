<div class="pull-right">
	<input type="text" name="invite_email" placeholder="Email for Invitation" value="" />
	<a class="btn btn-primary btn-small" type="button" onclick="org.inviteUser(<?=$data['domain_id']?>);">Invite New User</a>
	<?if($core->config['stage'] != 'production'){?>
	<!---
	<a class="btn btn-small" onclick="document.organizationsForm.invite_email.value='localorbit.testing+'+(new String((Math.floor(Math.random() * 1000))))+'@gmail.com';org.inviteUser(<?=$data['domain_id']?>);">Testing/qa only</a>
	-->
	<?}?>
</div>
<br />&nbsp;<br />

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
$users->add(new core_datacolumn('first_name','Name',true,'25%','<a href="#!users-edit--entity_id-{entity_id}"><b>{first_name} {last_name}</b>'));
$users->add(new core_datacolumn('email','E-mail',true,'25%','<a href="mailTo:{email}"><i class="icon icon-envelope" /> {email}</a>'));
$users->add(new core_datacolumn('created_at','Registered On',true,'15%','{created_at}'));

# They are an admin or a MM in their home hub so let them login as users
$actions = '';
if(lo3::is_market() ||  lo3::is_admin())
{
	$actions = '
		<div class="pull-right"><a class="btn btn-info btn-small" href="#!auth-loginas--entity_id-{entity_id}"><i class="icon-arrow-right" /> log in</a> 
		<a class="btn btn-warning btn-small" href="javascript:core.doRequest(\'/users/{enable_action}\',{\'entity_id\':{entity_id},\'table\':\'org_users\'});"><i class="icon-{enable_icon}" /> {enable_action}</a> ';
}
else
{
	$actions = '<div class="pull-right"><a class="btn btn-warning btn-small" href="javascript:core.doRequest(\'/users/{enable_action}\',{\'entity_id\':{entity_id},\'table\':\'org_users\'});"><i class="icon-{enable_icon}" /> {enable_action}</a> ';
}
$actions .= '<a class="btn btn-danger btn-small" href="#!organizations-edit--org_id-{org_id}" onclick="org.deleteUser({entity_id},this,'.$core->session['user_id'].');"><i class="icon-ban-circle" /> Delete</a></div>';
$users->add(new core_datacolumn('entity_id','&nbsp;',false,'35%',$actions,' ',' '));

$users->columns[2]->autoformat='date-short';
$users->display_filter_resizer = false;
$users->display_exporter_pager = false;
$users->size = (-1);
$users->render();
?>
