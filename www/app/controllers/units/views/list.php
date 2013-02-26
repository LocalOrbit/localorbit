<?php
core::ensure_navstate(array('left'=>'left_dashboard'), 'units-list','products-delivery');
core_ui::fullWidth();
core::head('Units','Units');
lo3::require_permission();
lo3::require_login();

lo3::require_orgtype('admin');

$col = core::model('Unit')->collection();
$units = new core_datatable('units','units/list',$col);
$units->add(new core_datacolumn('NAME','Single',true,'20%','<a href="#!units-edit--UNIT_ID-{UNIT_ID}">{NAME}</a>','{NAME}','{NAME}'));
$units->add(new core_datacolumn('PLURAL','Plural',true,'70%','<a href="#!units-edit--UNIT_ID-{UNIT_ID}">{PLURAL}</a>','{PLURAL}','{PLURAL}'));
$units->add(new core_datacolumn('PLURAL',' ',false,'10%','<a class="btn btn-small btn-danger" href="#!units-list" onclick="if(confirm(\'Are you sure you want to delete this unit?\')){core.doRequest(\'/units/delete\',\'&UNIT_ID={UNIT_ID}\');return false;}"><i class="icon-minus" /> Delete</a>',' ',' '));

$units->add_filter(new core_datatable_filter('name','concat_ws(\' \',Unit.NAME,Unit.PLURAL)','=~'));
$units->filter_html .= core_datatable_filter::make_text('units','name',$units->filter_states['products__filter__name'],'Search by name');


page_header('Units','#!units-edit','Create new unit', null,null, 'cube');
$units->render();
?> 