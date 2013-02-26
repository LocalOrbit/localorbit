<?php

core::ensure_navstate(array('left'=>'left_dashboard'), 'units-list','products-delivery');
core::head('Edit Unit','This page is used to edit product units');
lo3::require_permission();
lo3::require_login();

# only admins can edit units
lo3::require_orgtype('admin');

# load the data if we're passed an ID. Otherwise, we're building a new unit
$data = (is_numeric($core->data['UNIT_ID']))?core::model('Unit')->load():array();

# write out the validation rules
$this->save_rules()->js();

# write out the form
echo(
	core_form::page_header('Editing '.$data['SINGLE'],'#!units-list','cancel').
	core_form::form('unitsForm','/units/update','',
		core_form::tab_switchers('unittabs',array('Unit')),
		core_form::tab('unittabs',
			core_form::table_nv(
				core_form::input_text('Single','NAME',$data,array('required'=>true)),
				core_form::input_text('Plural','PLURAL',$data,array('required'=>true))
			)
		),
		core_form::input_hidden('UNIT_ID',$data),
		core_form::save_buttons()
	)
);
?>