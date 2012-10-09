<form>
	<h1>Login or register to continue</h1>
	In order to place your order, you must have an account on <?=$core->config['domain']['name']?>.
	<div class="buttonset">
		<input type="button" onclick="$('#edit_popup').fadeOut('fast');location.href='#!auth-form--redirect_to_checkout-1';core.go('#!auth-form--redirect_to_checkout-1');" class="button_primary" value="Login" />
		<input type="button" onclick="$('#edit_popup').fadeOut('fast');location.href='#!registration-form--redirect_to_checkout-1-domain_id-<?=$core->config['domain']['domain_id']?>';core.go('#!registration-form--redirect_to_checkout-1-domain_id-<?=$core->config['domain']['domain_id']?>');" class="button_primary" value="Register" />
		<input type="button" onclick="$('#edit_popup').fadeOut('fast');" class="button_primary" value="cancel" />
	</div>	
</form>
<?
core::js("$('#edit_popup').fadeIn('fast');"); 
core::replace('edit_popup'); 
?>