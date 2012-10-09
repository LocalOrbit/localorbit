<?php
core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Edit Users','This page is used to edit users');
lo3::require_permission();
lo3::require_login();
global $data;
$data = core::model('customer_entity')->load();
$org  = core::model('organizations')->load($data['org_id']);

core::log('currently logged in as '.$core->session['user_id'].'/'.$core->session['org_id']);

if(lo3::is_admin())
{
	# do nothing, admins are just that cool
}
else if(lo3::is_market())
{
	# make sure this user is in the same domain as the mm.
	$org  = core::model('organizations');
	$org->autojoin(
			'left',
			'organizations_to_domains otd',
			'otd.org_id = organizations.org_id',
			array('otd.domain_id')
	);

	$org = $org->load($data['org_id']);
	if(!in_array($org['domain_id'],$core->session['domains_by_orgtype_id'][2]))
	{
		core::log('permission problem 1');
		lo3::require_orgtype('admin');
	}
}
else
{
	# if this is just a normal customer, make sure this customer has the 
	# same org as the current user
	if($data['org_id'] != $core->session['org_id'])
	{
		core::log('permission problem 2');
		lo3::require_orgtype('admin');
	}
}


# print different header if editing your own profile
if($core->data['me'] == '1') 
	page_header('Editing '.$data['first_name'].' '.$data['last_name']);
else
	page_header('Editing '.$data['first_name'].' '.$data['last_name'],'#!users-list','cancel');


# write out the javascript rules for this form
$this->edit_rules()->js();
?>
<form name="userForm" method="post" action="/users/save" target="uploadArea" onsubmit="return core.submit('/users/save',this);" enctype="multipart/form-data">
	<?=core_ui::tab_switchers('usertabs',array('User Info','Password Security'))?>
	<div class="tabarea" id="usertabs-a1">	
		<table class="form">
			<?=core_form::value('Organization','<a href="#!organizations-edit--org_id-'.$org['org_id'].'">'.$org['name'].'</a>')?>
			<?=core_form::input_text('First Name','first_name',$data,true)?>
			<?=core_form::input_text('Last Name','last_name',$data,true)?>
			<?=core_form::input_text('E-mail','email',$data,true)?>
		</table>
	</div>
	<div class="tabarea" id="usertabs-a2">	
		<table class="form">
			<?=core_form::input_password('New Password','password','')?>
			<?=core_form::input_password('Confirm Password','confirm_password','')?>
		</table>
	</div>
	<?
	if($core->data['me'] == '1') 
		save_only_button();
	else
		save_buttons();
	?>
	<input type="hidden" name="entity_id" value="<?=$data['entity_id']?>" />	
</form>
