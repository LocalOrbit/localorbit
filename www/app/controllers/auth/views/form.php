<?
core::js('location.href=\'/login.php\';');
core::deinit();
?>
<!--[if lt IE 7]>
<p class="warning" style="font-size: 1.5em;">
It looks like you're using Internet Explorer 6.0.  We're unable to support this browser.
</p>
<p>
You can update to <a href="http://www.microsoft.com/downloads/en/details.aspx?FamilyID=9ae91ebe-3385-447c-8a30-081805b2f90b&displaylang=en">IE 7 or 8</a> for free. We recommend a free browser such as <a href="http://www.mozilla.com/en-US/firefox/personal.html">Firefox</a> or <a href="http://www.google.com/chrome">Chrome</a>.
</p>
<![endif]-->
<? 
core::ensure_navstate(array('left'=>'left_hub_info'));
$this->rules()->js(); 
core_ui::tabset('logintabs');

if($core->data['redirect_to_checkout'] == 1)
{
	$core->config['postauth_url'] = '#!catalog-checkout';
}

?>
<h1>Log in to <?=$core->config['domain']['detailed_name']?></h1>

<form name="authform" action="auth/process" onsubmit="return core.submit('/auth/process',this);">
	<? ?>
	<div class="tabset" id="logintabs">
		<div class="tabswitch" id="logintabs-s1">
			User Info
		</div>
	</div>
	<div class="tabarea" id="logintabs-a1">
		
		<table class="form">
			<col width="150" />
			<col width="200" />
			<col width="20" />
			<col width="267" />
			<tr>	
				<td class="label"><?=$core->i18n['field:customer:email']?> </td>
				<td class="value"><input type="text" class="text" tabindex="1" name="email" value="" /></td>
				<td rowspan="2">&nbsp;&nbsp;</td>
				<td rowspan="2">
					<ul>
						<li><a href="#!registration-form--domain_id-<?=(($core->config['domain']['domain_id']==1)?0:$core->config['domain']['domain_id'])?>" tabindex="5"><?=$core->i18n['link:createaccount']?></a></li>
						<li><a href="#!auth-forgot_password" tabindex="4"><?=$core->i18n['link:forgotpassword']?></a></li>
					</ul>
					<!--<?if($core->config['stage'] == 'testing' || $core->config['stage'] == 'qa'){?>
					<br />
					<input type="button" value="Jonathon don't press this please" class="button_secondary" onclick="document.authform.email.value='TestCSR1@iqguys.com';document.authform.password.value='password';core.submit('/auth/process',document.authform);" />
					<?}?>
					-->
				</td>
			</tr>
			<tr>
				<td class="label"><?=$core->i18n['field:customer:password']?> </td>
				<td class="value"><input type="password" tabindex="2" class="text" name="password" value="" /></td>
			</tr>
		</table>
	</div>
	<div class="buttonset">
		<input type="submit" value="<?=$core->i18n['button:login']?>" tabindex="3" class="button_primary" />
	</div>

<br />&nbsp;<br />
	<input type="hidden" name="postauth_url" value="<?=$core->config['postauth_url']?>" />
</form>


<table>
	<col width="49%" />
	<col width="2%" />
	<col width="49%" />
	<tr>
		<td>
			<?if(trim($core->config['domain']['market_profile']) != ''){?>
				<h3>Market Info</h3>
				<?=$core->config['domain']['market_profile']?>
				<br />&nbsp;<br />
			<?}?>
		</td>
		<td>&nbsp;</td>
		<td>
			<?if(trim($core->config['domain']['market_policies']) != ''){?>
				<h3>Policies</h3>
				<?=$core->config['domain']['market_policies']?>
			<?}?>
		</td>
	</tr>
</table>
