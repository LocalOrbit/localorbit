<?
lo3::require_orgtype('market');
$this->template_pagestart();
$orgs = core::model('lo_order_deliveries')->get_sellers_for_deliveries(explode(' ',$core->data['lodeliv_id']));

$core->config['delivery_tools_buttons'] = true;
$first = true;

foreach($orgs as $org)
{
   if (!$first) {
      ?>
<div class="page-break">&nbsp;</div>
<?
   }
	$core->data['org_id'] = $org;
	$this->buyer_packing_slips(true);
   $first = false;
}
$this->template_pageend();
?>