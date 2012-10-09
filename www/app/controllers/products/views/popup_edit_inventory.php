<?
global $core;
$prod  = core::model('products')->load();
$inv = core::model('product_inventory')->collection()->filter('prod_id',$core->data['prod_id']);
$inv->next();

#print_r($inv->__row->__data);
#echo('num rows: '.$inv->__num_rows);

$edit = '#!products-edit--prod_id-'.$core->data['prod_id'];
$edit .= '-tabautoswitch_producttabs-2';
#tabautoswitch_
if($inv->__num_rows == 1 && $inv->__row->__data['lot_id'] == ''  && $inv->__row->__data['good_from'] == '' && $inv->__row->__data['expires_on'] == '')
{
	# check to make sure the product is in simple inv mode:
?>
<form name="invform" action="/products/save_inventory" onsubmit="return core.submit('/products/save_inventory',this);">
	<fieldset id="editInv">
		<legend>Inventory Info</legend>
		<table class="form">
			<tr>
				<td class="label">Stock:</td>
				<td class="value"><input type="text" name="qty" style="size: 100px !important;" value="<?=floatval($inv->__row['qty'])?>" /></td>
			</tr>
			<tr>
				<td class="value" colspan="2" style="padding: 3px;">
					Note: Please 
					<a href="javascript:$('#edit_popup').fadeOut('fast');location.href='<?=$edit?>';core.go('<?=$edit?>');">click here</a>
					to view your inventory information.	
				</td>
			</tr>
		</table>
		<input type="hidden" name="prod_id" value="<?=$prod['prod_id']?>" />
		<input type="hidden" name="inv_id" value="<?=$inv->__row['inv_id']?>" />
		<input type="hidden" name="call_method" value="popup" />
		
		
		<div class="buttonset">
			<input type="button" onclick="$('#edit_popup').fadeOut('fast');" class="button_primary" value="cancel" />
			<input type="submit" class="button_primary" value="save" />
		</div>		
	</fieldset>
</form>
<? 
}
else
{
	# write out a message saying that the user needs to go to 
	# the product edit page to edit this inventory
	?>
	This product uses advanced inventory. Please 
	<a href="javascript:$('#edit_popup').fadeOut('fast');location.href='<?=$edit?>';core.go('<?=$edit?>');">click here</a>
	 to view your inventory information.
	
	<div class="buttonset">
		<input type="button" onclick="$('#edit_popup').fadeOut('fast');" class="button_primary" value="cancel" />
	</div>	
	<?
}
core::js("$('#edit_popup').fadeIn('fast');"); 
core::replace('edit_popup'); 
?>
