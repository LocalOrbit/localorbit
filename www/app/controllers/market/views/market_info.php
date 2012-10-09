<?php global $data; ?>
<table class="form">
	<tr>
		<td class="label">Contact Name</td>
		<td class="value"><input type="text" name="secondary_contact_name" value="<?=$data['secondary_contact_name']?>" /></td>
	</tr>
	<tr>
		<td class="label">Contact E-mail</td>
		<td class="value"><input type="text" name="secondary_contact_email" value="<?=$data['secondary_contact_email']?>" /></td>
	</tr>
	<tr>
		<td class="label">Contact Telephone</td>
		<td class="value"><input type="text" name="secondary_contact_phone" value="<?=$data['secondary_contact_phone']?>" /></td>
	</tr>

	<tr id="pickup_label1">
		<td class="label">Store Closed Note</td>
		<td class="value"><textarea rows="5" cols="60" name="closed_note"><?=htmlentities($data['closed_note'])?></textarea></td>
	</tr>
	<tr id="pickup_label1">
		<td class="label">Market Profile</td>
		<td class="value"><textarea rows="3" cols="60" name="market_profile"><?=htmlentities($data['market_profile'])?></textarea></td>
	</tr>
	<tr id="pickup_label2">
		<td class="label">Market Policies</td>
		<td class="value"><textarea rows="3" cols="60" name="market_policies"><?=htmlentities($data['market_policies'])?></textarea></td>
	</tr>
	<tr>
		<td class="label">Buyer Types</td>
		<td class="value"><input type="text" name="buyer_types_description" value="<?=$data['buyer_types_description']?>" /></td>
	</tr>
	<? if(lo3::is_admin())
	{?>
	<tr>
		<td class="label">Support Option</td>
		<td class="value">
			<select name="support_option">
				<option value="lo_managed">Local Orbit Managed</option>
				<option value="self_managed">Self-Managed</option>
				<option value="ext_managed">Externally Managed</option>
			</select>
		</td>
	</tr>
	<tr>
		<td class="label">&nbsp;</td>
		<td class="value"><?=core_ui::checkdiv('custom_zendesk','Custom Zendesk')?></td>
	</tr>
	<?}?>
	<tr>
		<td colspan="2">
			<? 
			$logo = image('profile',$data['domain_id']);
			$has_custom = (strpos($logo,'default') === false);
			?>
			<img src="<?=$logo?>?_time_=<?=$core->config['time']?>" id="logo3" />
			<div class="buttonset">
				<table class="form">
					<tr>
						<td class="label">Profile</td>
						<td class="value">
							<input type="file" name="profile" value="" />
							<input type="button" class="button_secondary" value="Upload" onclick="core.ui.uploadFrame(document.marketForm,'uploadArea3','market.refreshLogo3({params});','app/market/save_logo3');" />
							<input type="button" id="removeLogo3"<?=(($has_custom)?'':' style="display:none;"')?> class="button_secondary" value="Remove Image" onclick="core.doRequest('/market/remove_logo3','&domain_id=<?=$data['domain_id']?>')" />
							<br />
							Note: images can not be larger than 600 pixels wide by 500 pixels tall.<br />
							For best results, use images that are exactly 600 pixels wide by 500 pixels tall.
						</td>
					</tr>
				</table>
			</div>
			<iframe name="uploadArea3" id="uploadArea3" width="300" height="20" style="color:#fff;background-color:#fff;overflow:hidden;"></iframe>
		</td>
	</tr>
</table>