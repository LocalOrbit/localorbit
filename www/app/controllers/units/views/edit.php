<?php

core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Edit Unit','This page is used to edit product units');
lo3::require_permission();
lo3::require_login();

lo3::require_orgtype('admin');

core_ui::tabset('unittabs');
core_ui::rte();

if(!is_numeric($core->data['UNIT_ID']))
{
	$data = array();
}
else
{
	$data = core::model('Unit')->load();
}


page_header('Editing '.$data['SINGLE'],'#!units-list','cancel');
?>

<form name="unitsForm" method="post" action="/units/update" onsubmit="return core.submit('/units/update',this);" enctype="multipart/form-data">
	<div class="tabset" id="unittabs">
		<div class="tabswitch" id="unittabs-s1">
			Unit
		</div>
	</div>
	<div class="tabarea" id="unittabs-a1">
		<table class="form">
			<?=core_form::input_text('Single','NAME',$data,true)?>
			<?=core_form::input_text('Plural','PLURAL',$data,true)?>
		</table>
	</div>
	<input type="hidden" name="UNIT_ID" value="<?=$data['UNIT_ID']?>" />
	<? save_buttons(); ?>
</form>