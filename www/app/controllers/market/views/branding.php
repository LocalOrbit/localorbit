<?php global $data; ?>
<table class="form">
	<tr>
		<td class="label">Dashboard Note</td>
		<td class="value"><input type="text" name="dashboard_note" value="<?=$data['dashboard_note']?>" /></td>
	</tr>
	<tr>
		<td class="label">Note Offset</td>
		<td class="value"><input type="text" name="bubble_offset" value="<?=$data['bubble_offset']?>" /><?=info('Use this field to manually adjust the position of the dashboard note to account for extra wide logos')?></td>
	</tr>
	<tr>
		<td class="label">Custom Tagline</td>
		<td class="value"><input type="text" name="custom_tagline" value="<?=$data['custom_tagline']?>" /></td>
	</tr>
</table>
<? 
$logo = image('logo-large',$data['domain_id']);
$has_custom = (strpos($logo,'default') === false);
?>
<div class="form_divider">&nbsp;</div>
<img src="<?=$logo?>" id="logo1" />

<table class="form">
	<tr>
		<td class="label">Main Logo</td>
		<td class="value">
			<input type="file" name="logo_image" value="" />
			<?=info('Note: images can not be larger than 400 pixels wide by 400 pixels tall.<br />For best results, use images that are exactly 400 pixels wide by 400 pixels tall.<br />If you do not upload a logo, the default Local Orbit logo will be used.','paperclip',true);?>
			<br />
			<input type="button" class="button_secondary" value="upload" onclick="core.ui.uploadFrame(document.marketForm,'uploadArea1','market.refreshLogo1({params});','app/market/save_logo1');" />
			<input type="button" id="removeLogo1"<?=(($has_custom)?'':' style="display:none;"')?> class="button_secondary" value="remove image" onclick="core.doRequest('/market/remove_logo1','&domain_id=<?=$data['domain_id']?>')" />
			<br />
			
		</td>
	</tr>
</table>

<? 
$logo = image('logo-email',$data['domain_id']);
$has_custom = (strpos($logo,'default') === false);
?>
<div class="form_divider">&nbsp;</div>
<img src="<?=$logo?>" id="logo2" />
<table class="form">
	<tr>
		<td class="label">E-mail Logo</td>
		<td class="value">
			<input type="file" name="email_image" value="" />
			<?=info('Note: images can not be larger than 100 pixels wide by 100 pixels tall.<br />For best results, use images that are exactly 100 pixels wide by 100 pixels tall.<br />If you do not upload a logo, the default Local Orbit logo will be used.','paperclip',true);?>
			<br />
			<input type="button" class="button_secondary" value="Upload" onclick="core.ui.uploadFrame(document.marketForm,'uploadArea2','market.refreshLogo2({params});','app/market/save_logo2');" />
			<input type="button" id="removeLogo2"<?=(($has_custom)?'':' style="display:none;"')?> class="button_secondary" value="Remove Image" onclick="core.doRequest('/market/remove_logo2','&domain_id=<?=$data['domain_id']?>')" />
			<br />
		</td>
	</tr>
</table>

<iframe name="uploadArea1" id="uploadArea1" width="300" height="20" style="color:#fff;background-color:#fff;overflow:hidden;"></iframe>
<iframe name="uploadArea2" id="uploadArea2" width="300" height="20" style="color:#fff;background-color:#fff;overflow:hidden;"></iframe>