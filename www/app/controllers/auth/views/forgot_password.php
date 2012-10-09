<?php

core::ensure_navstate(array('left'=>'left_blank'));
core::head('Forgot Password','This page is to reset your password');
lo3::require_permission();
$this->reset_rules()->js();
page_header($core->i18n['header:forgotpassword']);
?>
<form name="resetpass" action="auth/process_reset" onsubmit="return core.submit('/auth/process_reset',this);">
	<table>	
		<tr>	
			<td class="label"><?=$core->i18n['field:customer:email']?> </td>
			<td class="value"><input type="text" class="text" name="username" value="" /></td>
		</tr>
	</table>
	<div class="buttonset">
		<input type="submit" value="<?=$core->i18n['button:resetpassword']?>" class="button_primary" />
		<br />
		<?=$core->i18n['note:resetpassword']?>		
	</div>
</form>
