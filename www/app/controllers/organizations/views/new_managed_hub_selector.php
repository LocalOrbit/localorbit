<?
lo3::require_orgtype('admin');

if(!$data)
	$data = core::model('organizations')->load();
	
$noncurrent_domains_col = core::model('domains')->collection();

$noncurrent_domains_col->filter(
	'domains.domain_id',
	'not in',
	'(
		select otd.domain_id 
		from organizations_to_domains otd 
		where otd.org_id='.$data['org_id'].'
		and otd.orgtype_id=2
	)'
);

$noncurrent_domains = new core_datatable('noncurrentdomains','organizations/new_managed_hub_selector?org_id='.$data['org_id'],$noncurrent_domains_col);
$noncurrent_domains->add(new core_datacolumn('name','Name',true,'40%','<a href="#!market-edit--domain_id-{domain_id}">{name}</a>','{name}','{name}'));
$noncurrent_domains->add(new core_datacolumn('hostname','Domain',true,'40%','<a href="#!market-edit--domain_id-{domain_id}">{hostname}</a>','{hostname}','{hostname}'));
$noncurrent_domains->add(new core_datacolumn('hostname','&nbsp;',false,'20%','<a href="javascript:org.addManagedDomain({domain_id})">Add this hub</a>',' ',' '));

$noncurrent_domains->add_filter(new core_datatable_filter('noncurrentdomainsname','name','~'));
$noncurrent_domains->filter_html .= core_datatable_filter::make_text('noncurrentdomains','noncurrentdomainsname',$domains->filter_states['noncurrentdomains__filter__noncurrentdomainsname'],'Search by name');

?>
<div class="buttonset" id="currentButtons">
	<input type="button" class="button_secondary" value="Add New Managed Hub" onclick="org.toggleNewHubTable();" />
	<input type="button" class="button_secondary" value="Remove Checked" onclick="org.removeManagedHubs();" />
</div>

<div id="possibleHubs" style="display: none;">
	<br />
	<h2>Available Hubs</h2>
	<?=$noncurrent_domains->render();?>
	<div class="buttonset">
		<input type="button" class="button_secondary" value="Cancel" onclick="org.toggleNewHubTable();" />
	</div>
</div>