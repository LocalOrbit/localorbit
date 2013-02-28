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
		<?=core_form::input_textarea('Who','profile',$data,array(
			'sublabel'=>'Your organization\'s story',
			'required'=>true,
			'rows'=>5,
			'cols'=>50,
			'info'=>'Customers can view this field when viewing your farm profile or a product. Additionally, you can override this on a per-product basis.',
		))?>


		<?=core_form::input_textarea('How','product_how',$data,array(
			'sublabel'=>'Your products\' story',
			'required'=>true,
			'rows'=>5,
			'cols'=>50,
			'info'=>'Every product has a description of how it is made. The value of this field will be used for your default Long How. Additionally, you can override this on a per-product basis.',
		))?>
		
		<div class="control-group">
			<label for="profile" class="control-label">  
				Photo
				<span class="help-block">Note: images can not be larger than 400 pixels wide by 400 pixels tall.</span>
			</label>
			<div class="controls row">
				<div class="span3" id="imgContainer"><img class="pull-left img_upload_view" id="orgImg" src="<?=$webpath?>" /></div>
				<div class="span5">
					<input type="file" name="new_image" value="" />
					<input type="button" class="btn btn-mini" value="Upload" onclick="core.ui.uploadFrame(document.organizationsForm,'uploadArea','org.refreshImage({params});','app/organizations/save_image');" />
					<input type="button" id="removeLogo1" class="btn btn-mini btn-danger" value="Remove Image" onclick="core.doRequest('/organizations/remove_image',{'org_id':<?=$data['org_id']?>});" />
		
					<p class="alert alert-info help-block note">Note: images can not be larger than 400 pixels wide by 400 pixels tall. For best results, use images that are exactly 400 pixels wide by 400 pixels tall. If you do not upload a logo, the default Local Orbit logo will be used.</p>
					<iframe name="uploadArea" id="uploadArea" width="300" height="20" style="color:#fff;background-color:#fff;overflow:hidden;border:0;"></iframe><br />
					<?=core_ui::checkdiv('public_profile','Show my profile on Our Sellers page.',($data['public_profile'] == 1))?>	
				</div>					
			</div>
		</div>
	</div>
<?}?>