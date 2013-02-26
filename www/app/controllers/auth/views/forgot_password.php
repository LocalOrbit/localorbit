<?php

core::ensure_navstate(array('left'=>'left_blank'));
core::head('Forgot Password','This page is to reset your password');
lo3::require_permission();
$this->reset_rules()->js();
page_header($core->i18n['header:forgotpassword']);
?>
<form name="resetpass" action="auth/process_reset" class="form-horizontal border-less" onsubmit="return core.submit('/auth/process_reset',this);">
	<div class="control-group">
		<label class="control-label"><?=$core->i18n['field:customer:email']?></label>
		<div class="controls">
			<input type="text" class="text" name="username" value="" />
		</div>
	</div>
	<div class="control-group">
		<div class="controls">
		<input type="submit" value="<?=$core->i18n['button:resetpassword']?>" class="button_primary" />
		<br />
		<?=$core->i18n['note:resetpassword']?>
	</div>
	</div>
</form>
