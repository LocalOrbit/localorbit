<?php
	global $data,$core;
	
	if(!is_object($data))
		$data = core::model('organizations')->load($core->data['org_id']);
	if($data['org_id'] != $core->session['org_id'])
	{
		$pm_org = core::model('organizations')->load($data['org_id']);
		if(!in_array($pm_org['domain_id'],$core->session['domains_by_orgtype_id'][2]))
		{
			lo3::require_orgtype('admin');
		}
	}
	$col = core::model('organization_payment_methods')->collection()->filter('org_id','=',$data['org_id']);

	$pms = new core_datatable('payment_methods','organizations/payment_methods?org_id='.$data['org_id'],$col);
	$col->add_formatter('show_opm_id_button');
	# add the columns
	$pms->add(new core_datacolumn('label','Account Nickname',true,'25%','<a href="#!organizations-edit--org_id-{org_id}" onclick="org.editPaymentMethod({opm_id},\'{name_on_account}\',\'{account_type}\',\'{label}\',\'{nbr1_last_4}\',\'{nbr2_last_4}\');">{label}</a>','{label}','{label}'));
	$pms->add(new core_datacolumn('name_on_account','Name on Account',true,'20%','<a href="#!organizations-edit--org_id-{org_id}" onclick="org.editPaymentMethod({opm_id},\'{name_on_account}\',\'{account_type}\',\'{label}\',\'{nbr1_last_4}\',\'{nbr2_last_4}\');">{name_on_account}</a>','{name_on_account}','{name_on_account}'));
	$pms->add(new core_datacolumn('nbr1_last_4','Account #',true,'20%','<a href="#!organizations-edit--org_id-{org_id}" onclick="org.editPaymentMethod({opm_id},\'{name_on_account}\',\'{account_type}\',\'{label}\',\'{nbr1_last_4}\',\'{nbr2_last_4}\');">*****{nbr1_last_4}</a>','*****{nbr1_last_4}','*****{nbr1_last_4}'));
	$pms->add(new core_datacolumn('nbr2_last_4','Routing #',true,'20%','<a href="#!organizations-edit--org_id-{org_id}" onclick="org.editPaymentMethod({opm_id},\'{name_on_account}\',\'{account_type}\',\'{label}\',\'{nbr1_last_4}\',\'{nbr2_last_4}\');">*****{nbr2_last_4}</a>','*****{nbr2_last_4}','*****{nbr2_last_4}'));
	$pms->add(new core_datacolumn('opm_id','&nbsp;',false,'15%','{opm_id_button}','',''));
	$pms->add(new core_datacolumn('opm_id',core_ui::check_all('opmids'),false,'4%',core_ui::check_all('opmids','opm_id')));
	
	
	$pms->size = (-1);
	$pms->display_filter_resizer = false;
	$pms->display_exporter_pager = false;
	$pms->render_page_select = false;
	$pms->render_page_arrows = false;
	
	
	function show_opm_id_button($in_data)
	{
		global $data;
		
		if($data['opm_id'] == $in_data['opm_id'])
		{
			$in_data['opm_id_button'] = 'Default';
		}
		else
		{
			$in_data['opm_id_button'] = '<input type="button" class="btn btn-info" onclick="org.makePrimaryAccount('.$in_data['org_id'].','.$in_data['opm_id'].');" value="Make Default" />';
		}
		
		return $in_data;
	}
	
	
	?>
	<div id="paymentsTable">
	<?
	$pms->render();
	?>
	</div>
	<div id="addPaymentButton" class="pull-right">
		<a class="btn btn-info btn-small" onclick="org.editPaymentMethod(0,'','Business','');"><i class="icon-plus" /> New Bank Account</a>
		<a class="btn btn-danger btn-small" onclick="org.deletePaymentMethods(document.organizationsForm);"><i class="icon-trash" /> Remove Checked</a>
	</div>
	<div class="row">
		<div class="span3">&nbsp;</div>
		<fieldset class="span6" id="editPaymentMethod" style="display: none;">
			<legend>Bank Account Info</legend>
			<?=core_form::input_text('Account Nickname','pm_label')?>
			<?=core_form::input_text('Name on Account','name_on_account')?>
			<?=core_form::input_select('Account Type','account_type','',array('Business'=>'Business','Personal'=>'Personal'))?>
			<?=core_form::input_text('Account #','nbr1','',array('onfocus'=>"if(new String(this.value).indexOf('*')===0){this.value='';}"))?>
			<?=core_form::input_text('Routing #','nbr2','',array('onfocus'=>"if(new String(this.value).indexOf('*')===0){this.value='';}"))?>
			<?=core_form::input_hidden('opm_id','')?>
			<div class="form-actions pull-right" style="padding-bottom: 0px;margin-bottom: 0px;">
				<input type="button" class="btn btn-warning" value="Cancel" onclick="org.cancelPaymentChanges();" />
				<input type="button" class="btn btn-primary" value="Save This Bank Account" onclick="org.savePaymentMethod(document.organizationsForm);" />
			</div>
			<div class="form-actions pull-right" style="margin-top: 5px;padding-top: 0px;padding-right; 10px;">
				
				<a id="seclink" href="Javascript:org.securityAssurance(document.getElementById('seclink'));">Security Assurance</a>
				
			</div>
		</fieldset>
	</div>