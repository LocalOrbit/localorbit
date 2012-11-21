<div class="tabarea" id="orgtabs-a4">
	<?php
	global $data,$core;
	
	if(!is_object($data))
		$data = array('org_id'=>intval($core->data['org_id']));
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

	# add the columns
	$pms->add(new core_datacolumn('label','Label',true,'25%','<a href="#!organizations-edit--org_id-{org_id}" onclick="org.editPaymentMethod({opm_id},\'{name_on_account}\',\'{label}\',\'{nbr1_last_4}\',\'{nbr2_last_4}\');">{label}</a>','{label}','{label}'));
	$pms->add(new core_datacolumn('name_on_account','Name on Account',true,'25%','<a href="#!organizations-edit--org_id-{org_id}" onclick="org.editPaymentMethod({opm_id},\'{name_on_account}\',\'{label}\',\'{nbr1_last_4}\',\'{nbr2_last_4}\');">{name_on_account}</a>','{name_on_account}','{name_on_account}'));
	$pms->add(new core_datacolumn('nbr1_last_4','Account #',true,'25%','<a href="#!organizations-edit--org_id-{org_id}" onclick="org.editPaymentMethod({opm_id},\'{name_on_account}\',\'{label}\',\'{nbr1_last_4}\',\'{nbr2_last_4}\');">************{nbr1_last_4}</a>','************{nbr1_last_4}','************{nbr1_last_4}'));
	$pms->add(new core_datacolumn('nbr2_last_4','Routing #',true,'25%','<a href="#!organizations-edit--org_id-{org_id}" onclick="org.editPaymentMethod({opm_id},\'{name_on_account}\',\'{label}\',\'{nbr1_last_4}\',\'{nbr2_last_4}\');">************{nbr2_last_4}</a>','************{nbr2_last_4}','************{nbr2_last_4}'));
	$pms->render();
	
	#core::log('not here');
	
	
	?>
	<div class="buttonset" id="addPaymentButton">
		<input type="button" class="button_secondary" value="Add New Payment Method" onclick="org.editPaymentMethod(0,'','');" />
		<input type="button" class="button_secondary" value="Remove Checked" onclick="org.deletePaymentMethods(this.form);" />
	</div>
	<br />
	<fieldset id="editPaymentMethod" style="display: none;">
		<legend>Payment Method Info</legend>
		<table class="form">
			<tr>
				<td class="label">Label:</td>
				<td class="value"><input type="text" name="pm_label" value="" /></td>
			</tr>
			<tr>
				<td class="label">Name on Account:</td>
				<td class="value"><input type="text" name="name_on_account" value="" /></td>
			</tr>
			<tr>
				<td class="label">Account #:</td>
				<td class="value"><input type="text" name="nbr1" value="" onfocus="if(new String(this.value).indexOf('*')===0){this.value='';}" /></td>
			</tr>
			<tr>
				<td class="label">Routing #:</td>
				<td class="value"><input type="text" name="nbr2" value="" onfocus="if(new String(this.value).indexOf('*')===0){this.value='';}" /></td>
			</tr>
			
		</table>
		<input type="hidden" name="opm_id" value="" />
		<div class="buttonset">
			<input type="button" class="button_secondary" value="save this payment method" onclick="org.savePaymentMethod(this.form);" />
			<input type="button" class="button_secondary" value="cancel" onclick="org.cancelPaymentChanges();" />
		</div>
	</fieldset>
</div>

