<?php
lo3::require_permission();
lo3::require_login();


global $data;

$regions = core::model('directory_country_region')->collection()->filter('country_id','US');

if(!$data)
	$data = core::model('domains')->load();
	
if(!in_array($data['domain_id'],$core->session['domains_by_orgtype_id'][2]))
	lo3::require_orgtype('admin');
else
	lo3::require_orgtype('market');
	
$col = $data->get_addresses();
#core::log(print_r($col->to_hash('address_id'),true));
core::js('core.addresses='.json_encode($col->to_hash('address_id')).';');
echo('<div id="addressTable">');
core::model('addresses')->get_table('market',$col,'market/addresses?domain_id='.$core->data['domain_id']);
echo('</div>');
?>
<div class="buttonset unlock_area pull-right" id="addAddressButton"<?=(($core->session['sec_pin'] == 1 || lo3::is_market())?'':' style="display:none;"')?>>
	<input type="button" class="btn btn-info" value="Add New Address" onclick="core.address.editAddress('market',0);" />
	<input type="button" class="btn btn-danger" value="Remove Checked" onclick="core.address.removeCheckedAddresses(this.form);" />
</div>
<br />

<fieldset id="editAddress" style="display: none;">
	<legend>Address Info</legend>
		
	<script>
		$("input[name=address]").change(function(event){
			setLatLon();
		});
		$("input[name=city]").change(function(event){
			setLatLon();
		});
		$("input[name=postal_code]").change(function(event){
			setLatLon();
		});
		$("select[name=region_id]").change(function(event){
			setLatLon();
		});
		function setLatLon() {
			core.address.lookupLatLong($("input[name=address]").val(), $("input[name=city]").val(), $("select[name=region_id]").find('option:selected').text(), $("input[name=postal_code]").val());
		}	
	</script>

	<?=core_form::input_text('Address Label','label','','')?>
	<?=core_form::input_text('Address','address','','')?>
	<?=core_form::input_text('City','city','','')?>
	
	<div class="control-group">
		<label class="control-label" for="label">State</label>
			<div class="controls">
				<select name="region_id">
					<option value="0"></option>
					<?=core_ui::options($regions,null,'region_id','default_name')?>					
				</select>
			</div>
	</div>
	
	<?=core_form::input_text('Postal Code','postal_code','','')?>
	<?=core_form::input_text('Telephone','telephone','','')?>
	<?=core_form::input_text('Fax','fax','','')?>		
	
	<input type="hidden" name="delivery_instructions" id="delivery_instructions" value="" />
	<input type="hidden" name="latitude" id="latitude" value="" />
	<input type="hidden" name="longitude" id="longitude" value="" />
	<input type="hidden" name="address_id" value="" />
	<div class="buttonset form-actions">
		<input type="button" class="btn btn-warning" value="cancel" onclick="core.address.cancelAddressChanges();" />
		<input type="button" class="btn btn-primary" value="save this address" onclick="core.address.saveAddress('market');" />
	</div>
</fieldset>