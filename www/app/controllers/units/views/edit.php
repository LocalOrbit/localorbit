<?php

core::ensure_navstate(array('left'=>'left_dashboard'), 'units-list','products-delivery');
core::head('Edit Unit','This page is used to edit product units');
lo3::require_permission();
lo3::require_login();
core_ui::fullWidth();

# only admins can edit units
lo3::require_orgtype('admin');

# load the data if we're passed an ID. Otherwise, we're building a new unit
$data = (is_numeric($core->data['UNIT_ID']))?core::model('Unit')->load():array();

# write out the validation rules
$this->save_rules()->js();

# write out the form
page_header('Editing '.$data['NAME'],'#!units-list','cancel','cancel');
?>
<form name="unitsForm" class="form-horizontal" action="/units/update"
 method="post" id="unitsForm"
 onsubmit="return core.submit('/units/update',this);" enctype="multipart/form-data">
	<?=core_form::tab_switchers('unittabs',array('Unit'))?>
	<div class="tab-pane tabarea " id="unittabs-a1">
		<?=core_form::input_text('Single','NAME',$data,array('required'=>true))?>
		<?=core_form::input_text('Plural','PLURAL',$data,array('required'=>true))?>
		<?=core_form::input_hidden('UNIT_ID',$data)?>
	</div>
	<?=core_form::save_buttons()?>
</form>