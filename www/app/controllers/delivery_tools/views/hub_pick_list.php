<?
lo3::require_orgtype('market');
$this->template_pagestart();
$orgs = core::model('lo_order_deliveries')->get_sellers_for_deliveries(explode(' ',$core->data['lodeliv_id']));
$first = true;
foreach($orgs as $org)
{
      if (!$first) {
      ?>
<div class="page-break"/>
<?
   }
	$core->data['org_id'] = $org;
	$this->pick_list();
   $first = false;
}
$this->template_pageend();
?>