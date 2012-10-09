<?
lo3::require_orgtype('market');
$this->template_pagestart();
$orgs = core::model('lo_order_deliveries')->get_sellers_for_deliveries(explode(' ',$core->data['lodeliv_id']));
$core->config['delivery_tools_buttons'] = true;

foreach($orgs as $org)
{
	$core->data['org_id'] = $org;
	$this->order_summary();
	$core->config['delivery_tools_buttons'] = false;
}
$this->template_pageend();
?>