<?php
global $data;
$tab_id = $core->view[0];
$is_mm = $core->view[1];

# only render this tab if we need to
if($is_mm || isset($core->data['currentdomains_page']))
{
	if(!$data)
		$data = core::model('organizations')->load();
		
	# if this is a MM editing their own org, we can use the cached domain ids 
	# from their session. Otherwise we need to add a subquery for the domains 
	# that the org is a MM of
	$current_domains_col = core::model('domains')->autojoin(
			'left',
			'organizations_to_domains',
			'(organizations_to_domains.org_id = '.$data['org_id'].' and organizations_to_domains.domain_id =domains.domain_id)',
			array('organizations_to_domains.orgtype_id','organizations_to_domains.is_home')
		)->collection();
	if($data['org_id'] == $core->session['org_id'])
	{
		$current_domains_col->filter(
			'domains.domain_id',
			'in',
			$core->session['domains_by_orgtype_id'][2]
		);
	}
	else
	{
		$current_domains_col->filter(
			'domains.domain_id',
			'in',
			'(
				select otd.domain_id 
				from organizations_to_domains otd 
				where otd.org_id='.$data['org_id'].'
				and otd.orgtype_id=2
			)'
		);
	}

	function managed_hubs_radio_formatter($data)
	{
		$data['is_home_radio']  = core_ui::radiodiv(
			'is_home_'.$data['domain_id'],
			($data['is_home'] == 1)?'Current home hub':'Set as home hub',
			($data['is_home'] == 1),
			'set_as_home',
			false,
			'org.setHomeHub('.$data['domain_id'].');'
		);
		$data['is_home_pdfcsv'] = ($data['is_home'] == 1)?'[*]':'[ ]';
		return $data;
	}
	$current_domains_col->add_formatter('managed_hubs_radio_formatter');

	# setup the datatable
	$col_sizes = (lo3::is_admin())?array('5%','35%','40%','20%'):array(0,'45%','35%','20%');
	$current_domains = new core_datatable('currentdomains','organizations/managed_hubs?org_id='.$data['org_id'],$current_domains_col);
	$current_domains->size = (-1);
	$current_domains->display_filter_resizer = false;
	$current_domains->render_page_select = false;
	$current_domains->render_page_arrows = false;
	
	if(lo3::is_admin())
	{
		$current_domains->add(new core_datacolumn('domain_id',core_ui::check_all('domainids'),false,$col_sizes[0],core_ui::check_all('domainids','domain_id'),'[ ]','[ ]'));
	}
	$current_domains->add(new core_datacolumn('name','Name',true,$col_sizes[1],'<a href="#!market-edit--domain_id-{domain_id}">{name}</a>','{name}','{name}'));
	$current_domains->add(new core_datacolumn('hostname','Domain',true,$col_sizes[2],'<a href="https://{hostname}/app.php#!dashboard-home">switch to: {hostname}</a>','{hostname}','{hostname}'));
	$current_domains->add(new core_datacolumn('hostname','&nbsp;',false,$col_sizes[3],'{is_home_radio}','{is_home_pdfcsv}','{is_home_pdfcsv}'));
	?>
	<div class="tabarea" id="orgtabs-a<?=$tab_id?>">
		<div id="currentHubs">
			<h2>Currently Managed Hubs</h2>
			<?=$current_domains->render();?>
			<?if(lo3::is_admin()){ $this->new_managed_hub_selector(); }?>
		</div>
	</div>
<?}?>