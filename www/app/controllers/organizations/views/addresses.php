<div class="tabarea" id="orgtabs-a2">
	<?php
	global $data,$org_all_domains;
	#if (!isset($data))
	#	die ("This organizations/addresses module can not be called directly.");

	$regions = core::model('directory_country_region')->collection()->filter('country_id','US');

	if(!$data)
		$data = core::model('organizations')->load();
		
	# if this org isn't the same as the current user's org, then apply permissions
	if($data['org_id'] != $core->session['org_id'])
	{
		#core::log('here');
		# if this org's list of domains does NOT 
		# intersect the list of domains that the current 
		# user is a MM of, then they HAVE to be an admin to manage them
		if(count(array_intersect($org_all_domains,$core->session['domains_by_orgtype_id'][2])) == 0)
		{
			lo3::require_orgtype('admin');
		}
		else
		{
			lo3::require_orgtype('market');
		}
	}
	
	$addr_model = core::model('addresses');
	$col = $addr_model->collection()
		->filter('is_deleted',0)
		->filter('org_id',$data['org_id']);
		
	#core::log(print_r($col->to_hash('address_id'),true));
	core::js('core.addresses='.json_encode($col->to_hash('address_id')).';');
	$addr_model->get_table('organizations',$col,'organizations/addresses?org_id='.$core->data['org_id']);

	?>
	<div class="buttonset" id="addAddressButton">
		<input type="button" class="button_secondary" value="Add New Address" onclick="core.address.editAddress('organizations',0);" />
		<input type="button" class="button_secondary" value="Remove Checked" onclick="core.address.removeCheckedAddresses(this.form);" />
	</div>
	<br />

	<fieldset id="editAddress" style="display: none;">
		<legend>Address Info</legend>
		<table class="form">
			<tr>
				<td class="label">Label</td>
				<td class="value"><input type="text" name="label" value="" /></td>
			</tr>
			<tr>
				<td class="label"><?=$core->i18n['field:address:street']?></td>
				<td class="value"><input type="text" name="address" value="" onblur="core.address.lookupLatLong(this.form.address.value,this.form.city.value,this.form.region_id.options[this.form.region_id.selectedIndex].text,this.form.postal_code.value);" /></td>
			</tr>
			<tr>
				<td class="label"><?=$core->i18n['field:address:city']?></td>
				<td class="value"><input type="text" name="city" value="" onblur="core.address.lookupLatLong(this.form.address.value,this.form.city.value,this.form.region_id.options[this.form.region_id.selectedIndex].text,this.form.postal_code.value);" /></td>
			</tr>
			<tr>
				<td class="label"><?=$core->i18n['field:address:state']?></td>
				<td class="value">
					<select name="region_id" onchange="core.address.lookupLatLong(this.form.address.value,this.form.city.value,this.form.region_id.options[this.form.region_id.selectedIndex].text,this.form.postal_code.value);">
						<option value="0"></option>
						<?=core_ui::options($regions,null,'region_id','default_name')?>					
					</select>
				</td>
			</tr>
			<tr>
				<td class="label"><?=$core->i18n['field:address:postalcode']?></td>
				<td class="value"><input type="text" name="postal_code" onblur="core.address.lookupLatLong(this.form.address.value,this.form.city.value,this.form.region_id.options[this.form.region_id.selectedIndex].text,this.form.postal_code.value);" value="" /></td>
			</tr>
			<tr>
				<td class="label"><?=$core->i18n['field:address:telephone']?></td>
				<td class="value"><input type="text" name="telephone" value="" /></td>
			</tr>
			<tr>
				<td class="label"><?=$core->i18n['field:address:fax']?></td>
				<td class="value"><input type="text" name="fax" value="" /></td>
			</tr>
			<tr>
				<td class="label"><?=$core->i18n['field:address:delivery_instructions']?></td>
				<td class="value"><input type="text" name="delivery_instructions" value="" /></td>
			</tr>
		</table>
		<div id="bad_address" class="info_area info_area_speech">We cannot locate your address. The address must be valid before you may save it.</div>
		<input type="hidden" name="latitude" id="latitude" value="" />
		<input type="hidden" name="longitude" id="longitude" value="" />
		<input type="hidden" name="address_id" value="" />
		<div class="buttonset">
			<input type="button" class="button_secondary" value="save this address" onclick="core.address.saveAddress('organizations');" />
			<input type="button" class="button_secondary" value="cancel" onclick="core.address.cancelAddressChanges();" />
		</div>
	</fieldset>
</div>