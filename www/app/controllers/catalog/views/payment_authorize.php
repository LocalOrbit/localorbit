<?
global $org;
if($org['payment_allow_authorize'] == 1)
{
	$style = ($core->view[0] > 1)?' style="display:none;"':'';
?>
<table id="payment_authorize" class="payment_option form"<?=$style?>>
	<tr>
		<td class="label">PO #</td>
		<td class="value"><input type="text" name="po_number" value="" /></td>
	</tr>
</table>
<?}?>