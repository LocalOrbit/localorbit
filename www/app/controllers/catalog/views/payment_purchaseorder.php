<?
global $core;
global $org;
if($org['payment_allow_purchaseorder'] == 1)
{
	$style = ($core->view[0] > 1)?' style="display:none;"':'';
?>
<div id="payment_purchaseorder" class="payment_option span6 form"<?=$style?>>
	<h4>Purchase Order Information</h4>
	<br />
	<?=core_form::input_text('Purchase Order #','po_number','')?>
	<? if ($core->config['domain']['po_due_within_days'] > 0) { ?>
	Payment should be made in <?=$core->config['domain']['po_due_within_days']?> days.
	<? } ?>
</div>
<?}?>