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
				<h2>Admin Notes</h2>
				<input type="hidden" name="lo_oid" value="<?=$lo_oid?>" />
				<textarea style="width: 100%; height: 100%;" name="admin_notes" rows="5"><?=$admin_notes?></textarea>
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