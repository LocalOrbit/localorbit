This page is currently acting as a testbed for the new data table system. Ignore the code below. 
The new datatable syntax should be nearly identical to lo3, except when filters are concerned. I'm still working on that.
<?php  
core::head('this is a test','asdfasdfasdfsdf','sellers,miketest');
core::replace('center'); 
#core::ensure_navstate(array('left'=>'left_seller_list')); 

$col = core::model('customer_entity')->collection();
$col->__formatters[]='test_formatter';

function test_formatter($data,$format='html')
{
	$data['calc_id'] = $data['entity_id'] * 2;
	return $data;
}

$users = new core_datatable('customers','sellers/testtable',$col);
$users->add_filter(new core_datatable_filter('group_id'));
$users->add_filter(new core_datatable_filter('first_name','concat_ws(\' \',first_name,last_name)','~'));
$users->add_filter(new core_datatable_filter('createdat1','created_at','>','date'));
$users->add_filter(new core_datatable_filter('createdat2','created_at','<','date'));
$users->add(new core_datacolumn('entity_id','ID',true,'12%'));
$users->add(new core_datacolumn('group_id','Group ID',true,'12%'));
$users->add(new core_datacolumn('first_name','First Name',true,'32%','<a href="#sellers-viewuser--user_id-{entity_id}">{first_name}</a>'));
$users->add(new core_datacolumn('last_name','Last Name',true,'32%','<a href="#sellers-viewuser--user_id-{entity_id}">{last_name}</a>'));
$users->add(new core_datacolumn('entity_id','calc ID',false,'12%','<b>{calc_id}</b>','[{calc_id}]','{calc_id}'));

echo(core_datatable_filter::make_text('customers','first_name',$users->filter_states['concat_ws(\' \',cev1.value,cev2.value)'],'Name '));
echo(core_datatable_filter::make_date('customers','createdat1',$users->filter_states['createdat1'],'Created After '));
echo(core_datatable_filter::make_date('customers','createdat2',$users->filter_states['createdat2'],'Created Before '));
/*
echo(core_datatable_filter::make_select('customers','group_id',$users->filter_states['group_id'],array(
	__core_datatable_filter_nullval__=>'Show all user types',
	1=>'Show only Sellers',
	2=>'Show only Wholesale Buyers',
	3=>'Show only Retail Buyers',
)));
*/

core::replace('datatable_filters');
$users->filter_html .= core::getclear_position('datatable_filters');
$users->render();
?>

this is the our sellers page
