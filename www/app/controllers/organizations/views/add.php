<?php

core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Add organization','');
lo3::require_permission();
lo3::require_login();
core_ui::tabset('orgtabs');
$this->add_rules()->js();
$regions = core::model('directory_country_region')->collection()->filter('country_id','in',array('US','CA'))->sort('default_name')->sort('(country_id=\'CA\')');

$hubs = core::model('domains')->collection();						
if (lo3::is_market()) { 
	$hubs = $hubs->filter('domain_id', 'in', implode(',', $core->session['domains_by_orgtype_id'][2]));							
} 
$hubs = $hubs->sort('name');

page_header('Create an organization','#!organizations-list','cancel');
?>
<form name="organizationsForm" method="post" action="/organizations/add_new" onsubmit="return core.submit('/organizations/add_new',this);" enctype="multipart/form-data">
	<div class="tabset" id="orgtabs">
		<div class="tabswitch" id="orgtabs-s1">
			Organization Info
		</div>
	</div>
	<div class="tabarea" id="orgtabs-a1">
		<table class="form">

			<tr>
				<td class="label">Name</td>
				<td class="value"><input type="text" name="name" value="<?=$data['name']?>" /></td>
			</tr>
			<tr>
				<td class="label">Hub</td>
				<td class="value">
					<select name="domain_id">
					<?=core_ui::options($hubs,$data['domain_id'],'domain_id','name');?>
					</select>
				</td>
			</tr>
			<tr>
				<td class="label">&nbsp;</td>
				<td class="value"><?=core_ui::checkdiv('allow_sell','Allowed to sell products',$data['allow_sell'])?></td>
			</tr>
			<tr>
				<td colspan="2"><h3>Address Info</h3></td>
			</tr>
			<tr>
				<td class="label">Label</td>
				<td class="value"><input type="text" name="label" value="Default" /></td>
			</tr>
			<tr>
				<td class="label">Address</td>
				<td class="value"><input type="text" name="address" value="" /></td>
			</tr>
			<tr>
				<td class="label">City</td>
				<td class="value"><input type="text" name="city" value="" /></td>
			</tr>
			<tr>
				<td class="label">State</td>
				<td class="value">
					<select name="region_id">
							<option value="0"></option>
							<?=core_ui::options($regions,null,'region_id','default_name')?>					
					</select>
				</td>
			</tr>
			<tr>
				<td class="label">Postal Code</td>
				<td class="value"><input type="text" name="postal_code" value="" /></td>
			</tr>
			<tr>
				<td class="label">Telephone</td>
				<td class="value"><input type="text" name="telephone" value="" /></td>
			</tr>
			<tr>
				<td class="label">Fax</td>
				<td class="value"><input type="text" name="fax" value="" /></td>
			</tr>
		</table>
	</div>
	<?
		save_only_button();
	?>
</form>