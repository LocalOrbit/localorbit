<?php

if($core->data['me'] == '1') 
{
	core::ensure_navstate(array('left'=>'left_dashboard'),'organizations-edit-me', 'account');
}
else
{
	core::ensure_navstate(array('left'=>'left_dashboard'),
		array('organizations-list', 'organizations-list', '', 'organizations-edit'), 
		array('market-admin', 'market-admin', '', 'account'));
}
		

core_ui::fullWidth();

core::head('Edit organizations','This page is used to edit organizations');
lo3::require_permission();
lo3::require_login();


# load the data needed for this form and store it into misc global vars
global $data,$domains,$all_domains,$org_all_domains;
$data = core::model('organizations')->load();
core::log('loading org '.$data['org_id']);
$all_domains = core::model('domains')->collection()->sort('name');
$org_domains = core::model('organizations_to_domains')->collection()->filter('org_id',$data['org_id']);
list(
	$org_home_domain_id,
	$org_all_domains,
	$org_domains_by_orgtype_id
) = core::model('customer_entity')->get_domain_permissions( $data['org_id']);
//print_r($org_all_domains);
$is_mm = (count($org_domains_by_orgtype_id[2]) > 0);

# get a list of domains whch this org can cross sell on
$domains = core::model('domains')
	->collection()
	->filter(
		'domain_id',
		'in',
		'(
			select domain_id 
			from domain_cross_sells 
			where accept_from_domain_id in ('.implode(',',$org_all_domains).')
		)'
	)->sort('name')->load();
$this->save_rules($data['allow_sell'] == 1)->js();

# kick out a normal customer trying to view any other org
if(lo3::is_customer() && $data['org_id'] != $core->session['org_id'])
{
	#core::log('here');
	core::log('redirect 1');
	lo3::require_orgtype('admin');
}

# kick out a market manager trying to view an org from another domain
if(lo3::is_market() && !in_array($org_home_domain_id,$core->session['domains_by_orgtype_id'][2]))
{
	#core::log('here');
	core::log('redirect 2');
	lo3::require_orgtype('admin');
}


# javascript to load org-editing-specific functionality
core_ui::load_library('js','org.js');
core_ui::load_library('js','address.js');

# determine which tabs we're going to show, and store the right tabid
$tabs = array('Organization Info','Addresses','Users','Bank Accounts');
if(
	$data['allow_sell'] == 1 and 
	$domains->__num_rows > 0 and
	(
		!lo3::is_customer() || 
		(lo3::is_customer() && $data['feature_sellers_cannot_manage_cross_sells'] == 0)
	)
)
{
	$tabs[] = 'Cross Sell';
	$crosssell_tab_id = count($tabs);
}
if($data['allow_sell'] == 1)
{
	$tabs[] = 'Seller Profile';
	$profile_tab_id = count($tabs);
}
if($is_mm && lo3::is_admin())
{
	$tabs[] = 'Managed Hubs';
	$managehubs_tab_id = count($tabs);
}

# print out the form
page_header('Editing Organization: '.$data['name'],'#!organizations-list','Cancel', 'cancel', null, 'grid');

if($data['is_deleted'] == 1)
{
	echo('<div class="alert alert-error">This organization has been deleted.</div>');
}
?>
<form class="form-horizontal" name="organizationsForm" method="post" action="/organizations/save" onsubmit="return core.submit('/organizations/save',this);" enctype="multipart/form-data">
	<?=core_ui::tab_switchers('orgtabs',$tabs)?>
	
	<div class="tab-content">
		<div class="tab-pane active" id="orgtabs-a1"><? $this->info($is_mm); ?></div>
		<div class="tab-pane" id="orgtabs-a2"><? $this->addresses(); ?></div>
		<div class="tab-pane" id="orgtabs-a3"><? $this->users(); ?></div>
		<div class="tab-pane" id="orgtabs-a4"><? $this->payment_methods(); ?></div>
		<div class="tab-pane" id="orgtabs-a<?=$crosssell_tab_id?>"><? $this->cross_sell($crosssell_tab_id); ?></div>
		<div class="tab-pane" id="orgtabs-a<?=$profile_tab_id?>"><? $this->profile($profile_tab_id); ?></div>
		<div class="tab-pane" id="orgtabs-a<?=$managehubs_tab_id?>"><? $this->managed_hubs($managehubs_tab_id,$is_mm); ?></div>
	</div>
	
	<?
	if($core->data['me'] == '1') 
		save_only_button();
	else
		save_buttons();
	?>
	<input type="hidden" name="org_id" value="<?=$data['org_id']?>" />
</form>
