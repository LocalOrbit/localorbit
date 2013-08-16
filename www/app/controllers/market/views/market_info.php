<?php 
global $data; 
$social_options = core::model('social_options')->collection()->to_array();
$addresses = $data->get_addresses();
$addresses->add_formatter('address_formatter');
?>

<div class="control-group">
	<label class="control-label">Contact Name</label>
	<div class="controls">
		<input type="text" name="secondary_contact_name" value="<?=$data['secondary_contact_name']?>" />
	</div>
</div>

<div class="control-group">
	<label class="control-label">Contact E-mail</label>
	<div class="controls">
		<input type="text" name="secondary_contact_email" value="<?=$data['secondary_contact_email']?>" />
	</div>
</div>

<div class="control-group">
	<label class="control-label">Contact Telephone</label>
	<div class="controls">
		<input type="text" name="secondary_contact_phone" value="<?=$data['secondary_contact_phone']?>" />
	</div>
</div>

<div class="control-group">
	<label class="control-label" for="facebook">Facebook</label>
	<div class="controls">
		<div class="input-prepend">
		  	<span class="add-on">facebook.com/</span>
			<input type="text" name="facebook" class="input-small" value="<?=$data['facebook']?>" placeholder="Username" />
		</div>
	</div>
</div>

<div class="control-group">
	<label class="control-label" for="twitter">Twitter</label>
	<div class="controls">
		<div class="input-prepend">
		  	<span class="add-on">@</span>
		  	<input type="text" name="twitter" class="input-large" value="<?=$data['twitter']?>" placeholder="Username">
		</div>
	</div>
</div>


<div class="control-group">
	<label class="control-label" for="twitter">Display Feed on Profile Page</label>
	<div class="controls">
		<select name="social_option_id" style="width: 300px;">
			<option>None</option>
<?foreach ($social_options as $so) {?>
			<option value="<?=$so['social_option_id']?>"<?=$data['social_option_id']===$so['social_option_id']?'selected':''?>>
  				<?=$so['display_name']?>
  			</option>
<?}?>
		</select>
	</div>
</div>
<div class="control-group">
	<label class="control-label" for="address_id">Market Info Address</label>
	<div class="controls">
		<select name="address_id" style="width: 300px;">
			<option>None</option>
<?foreach ($addresses as $address) {?>
			<option value="<?=$address['address_id']?>"<?=$data['address_id']===$address['address_id']?' selected="selected"':''?>>
  				<?=$address['formatted_address']?>
  			</option>
<?}?>
		</select>
	</div>
</div>
<div class="control-group">
	<label class="control-label">
		Market Profile
		<?=core_ui::tool_tip("Market Profile", "Here is your opportunity to tell your market's story.  Why is your market best source for local food?   What makes your market unique?")?>			
	</label>
	<div class="controls">
		<textarea rows="5" class="input-xxlarge" name="market_profile"><?=$data['market_profile']?></textarea>
	</div>
</div>

<div class="control-group">
	<label class="control-label">
		Market Policies
		<?=core_ui::help_tip("Market Policies", "This information appears on the Market Info page.")?>
		<?=core_ui::tool_tip("Market Policies", "This is your chance to tell the market's story. We recommend that you do not copy and paste directly from your website.")?>	
	</label>
	<div class="controls">
		<textarea rows="5" class="input-xxlarge" cols="60" name="market_policies"><?=$data['market_policies']?></textarea>
	</div>
</div>

<? 
$logo = image('profile',$data['domain_id']);
$has_custom = (strpos($logo,'default') === false);
?>

<div class="control-group">
	<label class="control-label" for="specimage">
		Profile	
		<?=core_ui::help_tip("Profile", "This image will appear on the Market Info page.")?>
		<?=core_ui::tool_tip("Profile", "Select a profile image that best represents your business. Are you known for great service? Consider posting an image of your team members.  Or are you known for the best product? Insert an image of your team with a basket of products.")?>
	</label>
	<div class="controls row">
		<div class="span3"><img class="pull-left img-polaroid" src="<?=$logo?>?_time_=<?=$core->config['time']?>" id="logo3" /></div>
		<div class="span5">
			<input type="file" name="profile" value="" />
			<input type="button" class="btn btn-mini" value="Upload File" onclick="core.ui.uploadFrame(document.marketForm,'uploadArea3','market.refreshLogo3({params});','app/market/save_logo3');" />
			<input type="button" id="removeLogo3"<?=(($has_custom)?'':' style="display:none;"')?> class="btn btn-mini btn-danger" value="Remove Image" onclick="core.doRequest('/market/remove_logo3','&domain_id=<?=$data['domain_id']?>')" />

			<p class="alert alert-info help-block note">Note: images can not be larger than 600 pixels wide by 500 pixels tall. For best results, use images that are exactly 600 pixels wide by 500 pixels tall.</p>
			<iframe name="uploadArea3" id="uploadArea3" width="300" height="20" style="color:#fff;background-color:#fff;overflow:hidden; border: 0;"></iframe>
		</div>
			
	</div>
</div>

<div class="control-group">
	<label class="control-label">
		Store Closed Note	
		<?=core_ui::help_tip("Store Closed Note	", "This lets the buyers know the market is closed and when it will reopen.")?>
	</label>
	<div class="controls">
		<textarea rows="5" class="input-xxlarge" name="closed_note"><?=$data['closed_note']?></textarea>
	</div>
</div>