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
<form name="invform" action="/products/save_inventory" class="form-horizontal" onsubmit="return core.submit('/products/save_inventory',this);">
	<fieldset id="editInv">
		<legend>Inventory Info</legend>
		<?=core_form::input_text('Stock','qty',floatval($inv->__row['qty']), array('natural_numbers' => true))?>

		<input type="hidden" name="prod_id" value="<?=$prod['prod_id']?>" />
		<input type="hidden" name="inv_id" value="<?=$inv->__row['inv_id']?>" />
		<input type="hidden" name="call_method" value="popup" />

		Note: Please 
		<a href="javascript:$('#edit_popup').fadeOut('fast');location.href='<?=$edit?>';core.go('<?=$edit?>');">click here</a>
		to view your inventory information.	
		
		<div class="form-actions pull-right">
			<input type="button" onclick="$('#edit_popup').fadeOut('fast');" class="btn btn-warning" value="cancel" />
			<input type="submit" class="btn btn-primary" value="save" />
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
