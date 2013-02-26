<?
if ($core->data['load_popup'] == 'yes') {
	$obj = core::model('lo_order')->load($lo_oid = $core->data['lo_oid']);
	$admin_notes = $obj['admin_notes'];
?>
<form method="post" action="/orders/save_admin_notes" onsubmit="return core.submit('/orders/save_admin_notes',this);" enctype="multipart/form-data">
<?
} else {
	$lo_oid = $core->view[0];
	$admin_notes = $core->view[1];
}
?>
	<h4>Admin Notes</h4>
	<input type="hidden" name="lo_oid" value="<?=$lo_oid?>" />
	<textarea name="admin_notes" class="span6" rows="5"><?=$admin_notes?></textarea>
	<? 
	if ($core->data['load_popup'] == 'yes') {
		save_only_button(true,"$('#edit_popup').hide(300);");
	}else{
		save_only_button();
	}
	 ?>
<?
if ($core->data['load_popup'] == 'yes') {
	core::js("$('#edit_popup').fadeIn('fast');"); 
	core::replace('edit_popup'); 
?>
</form>
<?
	core::deinit();
}
?>