<?
global $core;
core_ui::load_library('js','org.js');
?>
<form id="organizationsForm" name="organizationsForm" class="form-horizontal" onsubmit="return core.submit('/organizations/save_payment_method',this);" action="/organizations/save_payment_method">
	<fieldset id="editInv">
		<legend>Bank Account Info</legend>
		<?=core_form::input_text('Account Nickname','pm_label')?>
		<?=core_form::input_text('Name on Account','name_on_account')?>
		<?=core_form::input_text('Account #','nbr1','',array('onfocus'=>"if(new String(this.value).indexOf('*')===0){this.value='';}"))?>
		<?=core_form::input_text('Routing #','nbr2','',array('onfocus'=>"if(new String(this.value).indexOf('*')===0){this.value='';}"))?>
		<input type="hidden" name="from_financials" value="yes" />
		<input type="hidden" name="tab" value="<?=$core->data['tab']?>" />
		<input type="hidden" name="group_key" value="<?=$core->data['group_key']?>" />
		<input type="hidden" name="from_financials" value="yes" />
		<input type="hidden" name="org_id" value="<?=$core->session['org_id']?>" />
		<div class="form-actions pull-right">
			<input type="button" onclick="$('#edit_popup').fadeOut('fast');" class="btn btn-warning" value="cancel" />
			<input type="submit" class="btn btn-primary" value="Save This Bank Account" onclick="return org.checkBankRouting(document.organizationsForm);" />
		</div>		
	</fieldset>
</form>
<?
core::js("$('#edit_popup').fadeIn('fast');"); 
core::replace('edit_popup'); 
?>
