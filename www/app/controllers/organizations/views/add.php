<?php

core::ensure_navstate(array('left'=>'left_dashboard'),'organizations-list','market-admin');
core_ui::fullWidth();
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

page_header('Create New Organization','#!organizations-list','cancel', 'link', null, 'cog');
?>

<form class="form-horizontal" name="organizationsForm" method="post" action="/organizations/add_new" onsubmit="return core.submit('/organizations/add_new',this);" enctype="multipart/form-data">

	<h3>Organization Info</h3>

	<div class="control-group">
		<label class="control-label" for="name">Name</label>
		<div class="controls">
			<input type="text" name="name" value="<?=$data['name']?>" />
		</div>
	</div>
	
	<div class="control-group">
		<label class="control-label" for="name">Hub</label>
		<div class="controls">
			<select name="domain_id">
				<?=core_ui::options($hubs,$data['domain_id'],'domain_id','name');?>
			</select>
		</div>
	</div>
	
	<?= core_form::input_check('Allowed to sell products','allow_sell',$data['allow_sell']); ?>

	<h3>Address Info</h3>
	
	<div class="control-group">
		<label class="control-label" for="label">Location Name</label>
		<div class="controls">
			<input type="text" name="label" value="" />
		</div>
	</div>
	
	<div class="control-group">
		<label class="control-label" for="address">Address</label>
		<div class="controls">
			<input type="text" name="address" value="" />
		</div>
	</div>
	
	<div class="control-group">
		<label class="control-label" for="city">City</label>
		<div class="controls">
			<input type="text" name="city" value="" />
		</div>
	</div>
	
	<div class="control-group">
		<label class="control-label" for="region_id">State</label>
		<div class="controls">
			<select name="region_id">
				<option value="0"></option>
				<?=core_ui::options($regions,null,'region_id','default_name')?>					
			</select>
		</div>
	</div>
	
	<div class="control-group">
		<label class="control-label" for="postal_code">Postal Code</label>
		<div class="controls">
			<input type="text" name="postal_code" value="" />
		</div>
	</div>
	
	<div class="control-group">
		<label class="control-label" for="telephone">Telephone</label>
		<div class="controls">
			<input type="text" name="telephone" value="" />
		</div>
	</div>
	
	<div class="control-group">
		<label class="control-label" for="fax">Fax</label>
		<div class="controls">
			<input type="text" name="fax" value="" />
		</div>
	</div>
	
	<? save_only_button(); ?>
</form>