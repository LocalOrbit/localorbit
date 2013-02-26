<?php global $data; ?>
<div class="control-group">
	<label class="control-label">Dashboard Note</label>
	<div class="controls">
		<textarea rows="5" class="input-xxlarge" name="dashboard_note"><?=htmlentities($data['dashboard_note'])?></textarea>
	</div>
</div>
<?
/*
<div class="control-group">
	<label class="control-label">Note Offset</label>
	<div class="controls">
		<input type="text" name="bubble_offset" value="<?=$data['bubble_offset']?>" /><?=info('Use this field to manually adjust the position of the dashboard note to account for extra wide logos')?>
	</div>
</div>
*/?>

<div class="control-group">
	<label class="control-label">Custom Tagline</label>
	<div class="controls">
		<input type="text" name="custom_tagline" class="input-xxlarge" value="<?=$data['custom_tagline']?>" maxlength="60" />
	</div>
</div>

<?
$logo = image('logo-large',$data['domain_id']);
$has_custom = (strpos($logo,'default') === false);
?>

<div class="control-group">
	<label class="control-label" for="specimage">Main Logo</label>
	<div class="controls row">
		<div class="span3"><img class="pull-left img-polaroid" id="logo1" src="<?=$logo?>" /></div>
		<div class="span5">
			<input type="file" name="logo_image" value="" />
			<input type="button" class="btn btn-mini" value="Upload File" onclick="core.ui.uploadFrame(document.marketForm,'uploadArea1','market.refreshLogo1({params});','app/market/save_logo1');" />
			<input type="button" id="removeLogo1"<?=(($has_custom)?'':' style="display:none;"')?> class="btn btn-mini btn-danger" value="Remove Image" onclick="core.doRequest('/market/remove_logo1',{'domain_id':<?=$data['domain_id']?>});" />

			<p class="alert alert-info help-block note">Note: images can not be larger than 400 pixels wide by 400 pixels tall. For best results, use images that are exactly 400 pixels wide by 400 pixels tall. If you do not upload a logo, the default Local Orbit logo will be used.</p>
			<iframe name="uploadArea1" id="uploadArea1" width="300" height="20" style="color:#fff;background-color:#fff;overflow:hidden;border:0;"></iframe>
		</div>

	</div>
</div>

<?
$logo = image('logo-email',$data['domain_id']);
$has_custom = (strpos($logo,'default') === false);
?>

<div class="control-group">
	<label class="control-label" for="email_image">E-mail Logo</label>
	<div class="controls row">
		<div class="span3"><img class="pull-left img-polaroid" id="logo2" src="<?=$logo?>" /></div>
		<div class="span5">
			<input type="file" name="email_image" value="" />
			<input type="button" class="btn btn-mini" value="Upload File" onclick="core.ui.uploadFrame(document.marketForm,'uploadArea2','market.refreshLogo2({params});','app/market/save_logo2');" />
			<input type="button" id="removeLogo2"<?=(($has_custom)?'':' style="display:none;"')?> class="btn btn-mini btn-danger" value="Remove Image" onclick="core.doRequest('/market/remove_logo2','&domain_id=<?=$data['domain_id']?>')" />

			<p class="alert alert-info help-block note">Note: images can not be larger than 100 pixels wide by 100 pixels tall. For best results, use images that are exactly 100 pixels wide by 100 pixels tall. If you do not upload a logo, the default Local Orbit logo will be used.</p>
			<iframe name="uploadArea2" id="uploadArea2" width="300" height="20" style="color:#fff;background-color:#fff;overflow:hidden;border:0;"></iframe>
		</div>

	</div>
</div>
