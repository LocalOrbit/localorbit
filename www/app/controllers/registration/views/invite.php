<?
core::ensure_navstate(array('left'=>'left_blank'));
core::head($core->i18n['title:reg'],$core->i18n['description:reg']);
lo3::require_permission();
core_ui::load_library('js','registration.js');

$this->invite_rules()->js();
?>
<form name="authform" action="registration/process" onsubmit="return core.submit('/registration/process_invite',this);">
	
	<div id="reg_mainform">
		<h1><?=$core->i18n['header:reg:mainform']?></h1>
		<table class="form">

			<tr>
				<td class="label"><?=$core->i18n['field:customer:firstname']?><span class="required">*</span></td>
				<td class="value">
					<input type="text" name="first_name" value="" />
					<!-- <?=info('this is a comment about first name','paperclip')?> -->
				</td>
			</tr>
			<tr>
				<td class="label"><?=$core->i18n['field:customer:lastname']?><span class="required">*</span></td>
				<td class="value">
					<input type="text" name="last_name" value="" />
					<!-- <?=info('this is a comment about first name','edit')?> -->
				</td>
			</tr>

			<tr>
				<td class="label"><?=$core->i18n['field:customer:password']?><span class="required">*</span></td>
				<td class="value"><input type="password" name="password" value="" /></td>
			</tr>
			<tr>
				<td class="label"><?=$core->i18n['field:customer:password-match']?><span class="required">*</span></td>
				<td class="value"><input type="password" name="password_confirm" value="" /></td>
			</tr>
			<tr>
				<td class="value" colspan="2">
					<h2><?=$core->i18n['header:reg:newsletter-signup']?></h2>
					<?=core_ui::checkdiv('subscribe_mailchimp',$core->i18n['field:reg:check-newsletter'])?>
				</td>
			</tr>
			<tr>
				<td class="value" colspan="2">
					<h2><?=$core->i18n['header:reg:tos']?><span class="required">*</span></h2>
					<?=core_ui::checkdiv('tos_approve',$core->i18n['field:reg:check-tos'])?>				
				</td>
			</tr>
		</table>

		<div class="buttonset">
			<input type="submit" value="<?=$core->i18n['button:signup']?>" class="button_primary" />
		</div>
	</div>
	
	<?if($core->config['stage'] == 'testing' || $core->config['stage'] == 'qa'){?>
	<br />
	<input type="button" value="Testing/QA ONLY" class="button_secondary" onclick="core.registration.fakeInviteFill();" />
	<?}?>
	
	<input type="hidden" name="org_id" value="<?=$core->data['org_id']?>" />
	<input type="hidden" name="email" value="<?=str_replace(' ','+',trim($core->data['email']))?>" />
	<input type="hidden" name="key" value="<?=$core->data['key']?>" />
</form>
<br />