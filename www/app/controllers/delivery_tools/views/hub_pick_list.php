<?
lo3::require_orgtype('market');
$this->template_pagestart();
$orgs = core::model('lo_order_deliveries')->get_sellers_for_deliveries(explode(' ',$core->data['lodeliv_id']));
foreach($orgs as $org)
{
	$core->data['org_id'] = $org;
	$this->pick_list();
}
$this->template_pageend();
?>