<?php
global $data;
$tab_id = $core->view[0];

if (!isset($data))
	die ("This organizations/profile module can not be called directly.");


list($has_image,$webpath,$filepath) = $data->get_image();

if($data['allow_sell'] == 1)
{
	?>
	<div class="tabarea" id="orgtabs-a<?=$tab_id?>">
		<table class="form">
			<tr>
				<td class="value" colspan="2">
					<div id="imgContainer">
						<img id="orgImg" src="<?=$webpath?>" />
					</div>
					<div class="buttonset">
						<input type="file" name="new_image" value="" />
						<input type="button" class="button_secondary" value="Upload" onclick="core.ui.uploadFrame(document.organizationsForm,'uploadArea','org.refreshImage({params});','app/organizations/save_image');" />
						<input type="button" id="removeLogo" class="button_secondary" value="Remove Image" onclick="core.doRequest('/organizations/remove_image',{'org_id':<?=$data['org_id']?>});" /> 
					</div>
					Note: images can not be larger than 400 pixels wide by 400 pixels tall.<br />
					<iframe name="uploadArea" id="uploadArea" width="300" height="20" style="color:#fff;background-color:#fff;overflow:hidden;"></iframe>
				</td>
			</tr>
			<tr>
				<td class="label">&nbsp;</td>
				<td class="value"><?=core_ui::checkdiv('public_profile','Show my profile on Our Sellers page.',($data['public_profile'] == 1))?></td>
			</tr>
			<?=core_form::input_textarea('Who','Your organization\'s story','profile',$data,true,5,50,'Customers can view this field when browsing the sellers on a hub. Additionally, you can override this on a per-product basis.')?>
			<?=core_form::input_textarea('How','Your products\' story','product_how',$data,true,5,50,'Every product has a description of how it is made. The value of this field will be used for your default How. Additionally, you can override this on a per-product basis.')?>
		</table>
	</div>
<?}?>