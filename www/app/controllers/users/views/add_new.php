<?php

core::ensure_navstate(array('left'=>'left_dashboard'),'users-list','market-admin');
core_ui::fullWidth();
core::head('Add new user','This page is used to add users');
lo3::require_permission();
lo3::require_login();

lo3::require_orgtype('market');
$this->add_rules()->js();

#$payables = core::model('v_invoices')->collection();
#$payables->html_dump();
	
echo(
	core_form::page_header('Adding new user').
	core_form::form('userAddForm','/users/save_new',null,
		core_form::table_nv(
			core_form::input_select('Organization','org_id',$data,core::model('organizations')->get_list_for_dropdown(),array(
				'default_show'=>true,
				'default_text'=>'Select an organization',
				'text_column'=>'org_name',
				'value_column'=>'org_id',
				'select_style'=>'width:300px;',
			)),
			core_form::input_text('First Name','first_name'),
			core_form::input_text('Last Name','last_name'),
			core_form::input_text('E-mail','email'),
			core_form::input_password('Password','password'),
			core_form::input_password('Confirm Password','password_confirm')
		),
		core_form::save_only_button(array('cancel_button' => true, 'on_cancel' => 'location.href=\'#!users-list\';core.go(\'#!users-list\');')),
		($core->config['stage'] == 'testing' || $core->config['stage'] == 'qa')?
			core_form::input_button('testing','Testing/QA',"var f=document.userAddForm;$(f.first_name).val('Mike');$(f.last_name).val('Thorn');$(f.email).val('localorbit.testing+'+(new Date().valueOf())+'@gmail.com');$(f.password).val('password');$(f.password_confirm).val('password');"):''
	)
);

?>
<!--
<form name="userAddForm" method="post" action="/users/save_new" target="uploadArea" onsubmit="return core.submit('/users/save_new',this);" enctype="multipart/form-data">
	<div class="tabset" id="usertabs">
		<div class="tabswitch" id="usertabs-s1">
			User Info
		</div>
	</div>
	<div class="tabarea" id="usertabs-a1">	
		<table class="form">
			<tr>
				<td class="label">Organization</td>
				<td class="value">
					<select name="org_id" style="width: 450px;">
						<option value="0"></option>
						<?=core_ui::options(core::model('organizations')->get_list_for_dropdown(),false,'org_id','org_name')?>
					</select>
				</td>
			</tr>
			<tr>
				<td class="label">First Name</td>
				<td class="value"><input type="text" name="first_name" value="" /></td>
			</tr>
			<tr>
				<td class="label">Last Name</td>
				<td class="value"><input type="text" name="last_name" value="" /></td>
			</tr>
			<tr>
				<td class="label">E-mail</td>
				<td class="value"><input type="text" name="email" value="" /></td>
			</tr>
			<tr>
				<td class="label">Password</td>
				<td class="value"><input type="password" name="password" value="" /></td>
			</tr>
			<tr>
				<td class="label">Confirm Password</td>
				<td class="value"><input type="password" name="password_confirm" value="" /></td>
			</tr>
		</table>
	</div>
	<?
	save_only_button();
	
	if($core->config['stage'] == 'testing' || $core->config['stage'] == 'qa')
	{
	?>
	<input type="button" class="button_secondary" value="Testing/QA only" onclick="var f=document.userAddForm;$(f.first_name).val('Mike');$(f.last_name).val('Thorn');$(f.email).val('localorbit.testing+'+(new Date().valueOf())+'@gmail.com');$(f.password).val('password');$(f.password_confirm).val('password');" />
	<?}?>
</form>

-->