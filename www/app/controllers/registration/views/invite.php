<?
core::ensure_navstate(array('left'=>'left_blank'));
core::head($core->i18n['title:reg'],$core->i18n['description:reg']);
lo3::require_permission();
core_ui::load_library('js','registration.js');

$this->invite_rules()->js();
$core->session['spammer_field'] = 'invite';
?>
<form name="authform" class="form-horizontal" action="registration/process_invite" onsubmit="return core.submit('/registration/process_invite',this);">
	
	<div id="reg_mainform">
		<h1><?=$core->i18n['header:reg:mainform']?></h1>
		<?=core_form::input_text($core->i18n['field:customer:firstname'],'first_name','',array('required'=>true))?>
		<?=core_form::input_text($core->i18n['field:customer:lastname'],'last_name','',array('required'=>true))?>
		<?=core_form::input_password($core->i18n['field:customer:password'],'password','',array('required'=>true))?>
		<?=core_form::input_password($core->i18n['field:customer:password-match'],'password_confirm','',array('required'=>true))?>
		
		<h2><?=$core->i18n['header:reg:newsletter-signup']?></h2>
		<?=core_ui::checkdiv('subscribe_mailchimp',$core->i18n['field:reg:check-newsletter'])?><br />
		<br />&nbsp;<br />
		
		<h2><?=$core->i18n['header:reg:tos']?><span class="required">*</span></h2>
		<?=core_ui::checkdiv('tos_approve',$core->i18n['field:reg:check-tos'])?>		
	

		<div class="buttonset form-actions">
			<input type="submit" value="<?=$core->i18n['button:signup']?>" class="btn btn-primary" />
		</div>
	</div>
	
	<?if($core->config['stage'] == 'testing' || $core->config['stage'] == 'qa'){?>
	<br />
	<input type="button" value="Testing/QA ONLY" class="button_secondary" onclick="core.registration.fakeInviteFill();" />
	<?}?>
	<input type="hidden" name="<?=$core->session['spammer_field']?>" value="invite" />
	
	<input type="hidden" name="org_id" value="<?=$core->data['org_id']?>" />
	<input type="hidden" name="email" value="<?=str_replace(' ','+',trim($core->data['email']))?>" />
	<input type="hidden" name="key" value="<?=$core->data['key']?>" />
</form>
<br />