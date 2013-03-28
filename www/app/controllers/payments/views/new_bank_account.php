<?
global $core;

?>
<form name="bankForm" action="/organizations/save_payment_method" class="form-horizontal" onsubmit="return core.submit('/organizations/save_payment_method',this);">
	<fieldset id="editInv">
		<legend>Bank Account Info</legend>
		<?=core_form::input_text('Account Nickname','pm_label')?>
		<?=core_form::input_text('Name on Account','name_on_account')?>
		<?=core_form::input_text('Account #','nbr1','',array('onfocus'=>"if(new String(this.value).indexOf('*')===0){this.value='';}"))?>
		<?=core_form::input_text('Routing #','nbr2','',array('onfocus'=>"if(new String(this.value).indexOf('*')===0){this.value='';}"))?>
		<input type="hidden" name="from_financials" value="yes" />
		<input type="hidden" name="org_id" value="<?=$core->session['org_id']?>" />
		<div class="form-actions pull-right">
			<input type="button" onclick="$('#edit_popup').fadeOut('fast');" class="btn btn-warning" value="cancel" />
			<input type="submit" class="btn btn-primary" value="Save This Bank Account" />
		</div>		
	</fieldset>
</form>
<?
core::js("$('#edit_popup').fadeIn('fast');"); 
core::replace('edit_popup'); 
?>
