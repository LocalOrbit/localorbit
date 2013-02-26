<?php
global $data,$org_all_domains;


#if (!isset($data))
#	die ("This organizations/addresses module can not be called directly.");

$regions = core::model('directory_country_region')->collection()->filter('country_id','US');

if(!$data)
	$data = core::model('organizations')->load($core->data['org_id']);
		
if(!is_array($org_all_domains))
{
	list(
		$org_home_domain_id,
		$org_all_domains,
		$org_domains_by_orgtype_id
	) = core::model('customer_entity')->get_domain_permissions( $data['org_id']);
}		
		
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
	->filter('addresses.is_deleted','=',0)
	->filter('org_id','=',$data['org_id']);
		
#core::log(print_r($col->to_hash('address_id'),true));
core::log('core.addresses='.json_encode($col->to_hash('address_id')).';');
core::js('core.addresses = '.json_encode($col->to_hash('address_id')).';');


?>
<div id="addressTable">
	<?
	$addr_model->get_table('organizations',$col,'organizations/addresses?org_id='.$core->data['org_id']);
	?>
	<div>
		<div class="pull-left">&nbsp;</div>
		<div id="addAddressButton" class="pull-right">
			<a class="btn btn-info btn-small" onclick="core.address.editAddress('organizations',0);"><i class="icon-plus" /> Add New Address</a>
			<a class="btn btn-danger btn-small" onclick="core.address.removeCheckedAddresses(document.organizationsForm);"><i class="icon-trash" /> Remove Checked</a>
		</div>
	</div>
</div>
<div class="row">
	<div class="span3">&nbsp;</div>
	<fieldset id="editAddress" class="span6" style="display: none;">
		<legend>Address Info</legend>
			
		<div class="control-group">
			<label class="control-label" for="domain_id">Location Name</label>
			<div class="controls">
				<input type="text" name="label" value="" />
			</div>
		</div>
			
		<div class="control-group">
			<label class="control-label" for="address"><?=$core->i18n['field:address:street']?></label>
			<div class="controls">
				<input type="text" name="address" value="" onblur="core.address.lookupLatLong(this.form.address.value,this.form.city.value,this.form.region_id.options[this.form.region_id.selectedIndex].text,this.form.postal_code.value);" />
			</div>
		</div>
			
		<div class="control-group">
			<label class="control-label" for="city"><?=$core->i18n['field:address:city']?></label>
			<div class="controls">
				<input type="text" name="city" value="" onblur="core.address.lookupLatLong(this.form.address.value,this.form.city.value,this.form.region_id.options[this.form.region_id.selectedIndex].text,this.form.postal_code.value);" />
			</div>
		</div>
			
		<div class="control-group">
			<label class="control-label" for="region_id"><?=$core->i18n['field:address:state']?></label>
			<div class="controls">
				<select name="region_id" onchange="core.address.lookupLatLong(this.form.address.value,this.form.city.value,this.form.region_id.options[this.form.region_id.selectedIndex].text,this.form.postal_code.value);">
					<option value="0"></option>
					<?=core_ui::options($regions,null,'region_id','default_name')?>					
				</select>
			</div>
		</div>
			
		<div class="control-group">
			<label class="control-label" for="postal_code"><?=$core->i18n['field:address:postalcode']?></label>
			<div class="controls">
				<input type="text" name="postal_code" onblur="core.address.lookupLatLong(this.form.address.value,this.form.city.value,this.form.region_id.options[this.form.region_id.selectedIndex].text,this.form.postal_code.value);" value="" />
			</div>
		</div>
			
		<div class="control-group">
			<label class="control-label" for="postal_code"><?=$core->i18n['field:address:telephone']?></label>
			<div class="controls">
				<input type="text" name="telephone" value="" />
			</div>
		</div>
			
		<div class="control-group">
			<label class="control-label" for="postal_code"><?=$core->i18n['field:address:fax']?></label>
			<div class="controls">
				<input type="text" name="fax" value="" />
			</div>
		</div>
			
		<div class="control-group">
			<label class="control-label" for="postal_code"><?=$core->i18n['field:address:delivery_instructions']?></label>
			<div class="controls">
				<input type="text" name="delivery_instructions" value="" />
			</div>
		</div>

		<div id="bad_address" class="alert alert-block info_area info_area_speech" style="display: none;">We cannot locate your address. The address must be valid before you may save it.</div>

		<input type="hidden" name="latitude" id="latitude" value="" />
		<input type="hidden" name="longitude" id="longitude" value="" />
		<input type="hidden" name="address_id" value="" />
		<? subform_buttons('core.address.saveAddress(\'organizations\');','Save This Address','core.address.cancelAddressChanges();'); ?>
	</fieldset>
	<div class="span3">&nbsp;</div>
</div>