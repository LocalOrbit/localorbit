<?
global $core;
global $org;
if($org['payment_allow_purchaseorder'] == 1)
{
	$style = ($core->view[0] > 1)?' style="display:none;"':'';
	print_r($core->session);
?>
<div id="payment_purchaseorder" class="payment_option form"<?=$style?>>
	<h3>Purchase Order Information</h3>
	<br />
	<table class="form">
		<!--<tr>
			<td colspan="2">Payment should be made in x days.</td>
		</tr>-->
		<tr>
			<td class="label">Purchase Order #</td>
			<td class="value"><input type="text" style="width: 150px;" name="po_number" value="" /></td>
		</tr>
	</table>
</div>
<?}?>