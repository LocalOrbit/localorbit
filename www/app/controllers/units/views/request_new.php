<?php
core::ensure_navstate(array('left'=>'left_dashboard'), 'units-list','products-delivery');
core::head('Request new unit');
lo3::require_permission();
lo3::require_login();
core_ui::tabset('unittabs');
page_header('Request new unit','#!products-edit--prod_id-'.$core->data['prod_id'],'cancel');
$this->rules()->js();
?>

<form name="unitsForm" method="post" action="/units/do_request" onsubmit="return core.submit('/units/do_request',this);" enctype="multipart/form-data">
	<div class="tabset" id="unittabs">
		<div class="tabswitch" id="unittabs-s1">
			Request Info
		</div>
	</div>
	<div class="tabarea" id="unittabs-a1">
		Adding new units to the system requires approval. Please enter the unit you'd like to have added. We'll have it added for you within 24 hours.
		<br />
		<table class="form">
			<tr>
				<td class="label">Product</td>
				<td class="value"><?=$core->data['prod_name']?><?=info('Once a new unit has been created, it can be used by any of your products')?></td>
			</tr>
			<tr>
				<td class="label">Single</td>
				<td class="value"><input type="text" name="single" value="" /></td>
			</tr>
			<tr>
				<td class="label">Plural</td>
				<td class="value"><input type="text" name="plural" value="" /></td>
			</tr>
			<tr>
				<td class="label">Additional Notes</td>
				<td class="value"><textarea name="additional_notes" rows="3" cols="60"></textarea></td>
			</tr>
		</table>
	</div>
	<input type="hidden" name="product_name" value="<?=$core->data['prod_name']?>" />
	<input type="hidden" name="prod_id" value="<?=$core->data['prod_id']?>" />
	<div class="buttonset">
		<input type="submit" class="button_primary" value="send request" />
	</div>
</form>