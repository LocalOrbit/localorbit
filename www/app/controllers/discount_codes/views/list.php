<?php
core::ensure_navstate(array('left'=>'left_dashboard'),'discount_codes-list','marketing');
core_ui::fullWidth();
core::head('Discount Codes','This page is to view discount codes');
lo3::require_permission();
lo3::require_login();
lo3::require_orgtype('market');

function row_formatter($data)
{
	$data['discount_amount'] = intval(abs($data['discount_amount']));
	
	if($data['domain_id'] == 0)
	{
		$data['domain_name'] = 'Everywhere';
	}
	
	$data['discount_type'] = '<strong>'.(($data['discount_type']=='Fixed')?'$':'%').'</strong>';
	
	if($data['nbr_uses_global'] != 0)
	{
		$data['available_uses'] = $data['nbr_uses_global'] - $data['nbr_discount_uses'];
	}
	else if ($data['nbr_uses_org'] != 0)
	{
		$data['available_uses'] = $data['nbr_uses_org'] - $data['nbr_discount_uses'];
	}
	else
	{
		$data['available_uses'] = 'Unlimited';
	}
	

	
	return $data;
}

$col = core::model('discount_codes')
	->add_custom_field('
		(select count(disc_use_id) from discount_uses WHERE discount_uses.disc_id=discount_codes.disc_id) as nbr_discount_uses
	')
	->collection();
$col->add_formatter('row_formatter');
if(!lo3::is_admin())
{
	$col->filter('discount_codes.domain_id','in',$core->session['domains_by_orgtype_id'][2]);
}

$discount_codes = new core_datatable('discount_codes','discount_codes/list',$col);

if(lo3::is_admin())
{
	$discount_codes->add_filter(new core_datatable_filter('discount_codes.domain_id'));
	$discount_codes->filter_html .= core_datatable_filter::make_select(
		'discount_codes',
		'discount_codes.domain_id',
		$discount_codes->filter_states['discount_codes__filter__discount_codes_domain_id'],
		new core_collection('select domain_id,name from domains order by name'),
		'domain_id',
		'name',
		'Show from all markets',
		'width: 250px;'
	);
}


$discount_codes->add(new core_datacolumn('domain_id','Market',true,'25%','<a href="#!discount_codes-edit--disc_id-{disc_id}">{domain_name}</a>','{domain_name}','{domain_name}'));

$discount_codes->add(new core_datacolumn('name','Discount Name',true,'15%','<a href="#!discount_codes-edit--disc_id-{disc_id}">{name}</a>','{name}','{name}'));
$discount_codes->add(new core_datacolumn('code','Code',true,'15%','<a href="#!discount_codes-edit--disc_id-{disc_id}">{code}</a>','{code}','{code}'));
$discount_codes->add(new core_datacolumn('discount_amount','Amount',true,'5%','<a href="#!discount_codes-edit--disc_id-{disc_id}">{discount_amount}</a>','{discount_amount}','{discount_amount}'));
$discount_codes->add(new core_datacolumn('discount_type','Type',true,'5%','<a href="#!discount_codes-edit--disc_id-{disc_id}">{discount_type}</a>','{discount_type}','{discount_type}'));
$discount_codes->add(new core_datacolumn('nbr_uses_global','Uses',true,'6%','<a href="#!discount_codes-edit--disc_id-{disc_id}">{nbr_discount_uses}</a>','{nbr_discount_uses}','{nbr_discount_uses}'));
$discount_codes->add(new core_datacolumn('nbr_uses_global','Available',true,'10%','<a href="#!discount_codes-edit--disc_id-{disc_id}">{available_uses}</a>','{available_uses}','{available_uses}'));
$discount_codes->add(new core_datacolumn('disc_id',' ',false,'24%','
	<a class="btn btn-small btn-danger" href="#!discount_codes-list" onclick="if(confirm(\'Are you sure you want to delete this discount?\')){core.doRequest(\'/discount_codes/delete\',\'&disc_id={disc_id}\');return false;}"><i class="icon-minus" /> Delete</a>
	<a class="btn btn-small btn-info" href="#!discount_codes-list" onclick="core.doRequest(\'/discount_codes/copy_code\',{\'disc_id\':{disc_id}});"><i class="icon-copy" /> Copy</a>
',' ',' '));
page_header('Discount Codes','#!discount_codes-edit','Create new code','button',null, 'tag');
$discount_codes->render();
?>