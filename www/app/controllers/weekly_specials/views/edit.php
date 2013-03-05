<?php

core::ensure_navstate(array('left'=>'left_dashboard'),'weekly_specials-list','marketing');
core_ui::fullWidth();
core::head('Buy and Sell Local Food on Local Orbit - Edit Weekly Specials','This page is used to edit Weekly Specials');
lo3::require_permission();
lo3::require_login();
core_ui::load_library('js','weeklySpecials.js');

core_ui::tabset('specialstabs');
//core_ui::rte();

$products = core::model('products')->get_list_for_dropdown();

$hubs = core::model('domains')->collection();						
if (lo3::is_market())
{ 
	$hubs = $hubs->filter('domain_id', 'in',$core->session['domains_by_orgtype_id'][2]);
} 
$hubs = $hubs->sort('name');

if(is_numeric($core->data['spec_id']))
	$data = core::model('weekly_specials')->load($core->data['spec_id']);
else
	$data = array('domain_id'=>$core->session['domains_by_orgtype_id'][2][0]);

# if the hub you were trying to edit is NOT the same as YOUR hub, then 
# make sure the user is actually an admin. Otherwise, they can be a market manager
if(!in_array($data['domain_id'],$core->session['domains_by_orgtype_id'][2]))
{
	lo3::require_orgtype('admin');
}
else
{
	lo3::require_orgtype('market');
}


$placeholder_image = '/img/blank.png';
$web_path = '/img/weeklyspec/'.$data['spec_id'].'.';
$fs_path  = $core->paths['base'].'/..'.$web_path;
if(file_exists($fs_path.'png'))	
	$image_path = $web_path.'png?_time_='.$core->config['time'];
else if(file_exists($fs_path.'jpg'))	
	$image_path = $web_path.'jpg?_time_='.$core->config['time'];
else if(file_exists($fs_path.'gif'))	
	$image_path = $web_path.'gif?_time_='.$core->config['time'];
else
	$image_path = $placeholder_image;
$has_custom = ($image_path != $placeholder_image);


page_header('Editing '.$data['name'],'#!weekly_specials-list','cancel', 'cancel');
?>

<form class="form-horizontal" name="specialsForm" method="post" action="/weekly_specials/update" onsubmit="return core.submit('/weekly_specials/update',this);" enctype="multipart/form-data">
	<div class="alert alert-success" id="deactivate"<?=(($data['is_active'] == 1)?'':' style="display:none;"')?>>
		This is the active promotion. If you would like to deactivate this promotion, 
		<a href="Javascript:$('#activate,#deactivate').toggle();core.doRequest('/weekly_specials/toggle_special',{'domain_id':<?=$data['domain_id']?>,'spec_id':<?=$data['spec_id']?>});">click here.</a>
	</div>
	<div class="alert" id="activate"<?=(($data['is_active'] == 1)?' style="display:none;"':'')?>>
		This is NOT the active promotion. If you would like to activate this promotion, 			
		<a href="Javascript:$('#activate,#deactivate').toggle();core.doRequest('/weekly_specials/toggle_special',{'domain_id':<?=$data['domain_id']?>,'spec_id':<?=$data['spec_id']?>});">click here.</a>
	</div>

	<?if(lo3::is_admin() || count($core->session['domains_by_orgtype_id'][2])>1){?>
		<div class="control-group">
			<label class="control-label" for="domain_id">Market</label>
			<div class="controls">
				<select name="domain_id" onchange="core.lo3.getUpdatedDataForSelector('get_products',this.options[this.selectedIndex].value,document.specialsForm.product_id,'Select a product');">
					<option value="0">Select a hub</option>
					<?=core_ui::options($hubs,$data['domain_id'],'domain_id','name')?>
				</select>
			</div>
		</div>
	<? } ?>
	
	<div class="control-group">
		<label class="control-label" for="name">Name</label>
		<div class="controls">
			<input type="text" class="input-xlarge" name="name" value="<?=$data['name']?>" />
		</div>
	</div>
	
	<div class="control-group">
		<label class="control-label" for="product_id">Product</label>
		<div class="controls">
			<select name="product_id" class="input-xxlarge" >
				<option value="0">Select a product</option>
				<?=core_ui::options($products,$data['product_id'],'prod_id','product_name')?>
			</select>
			
		</div>
	</div>
	
	<div class="control-group">
		<label class="control-label" for="title">Title</label>
		<div class="controls">
			<input type="text" name="title" value="<?=$data['title']?>" />
		</div>
	</div>
	
	<div class="control-group">
		<label class="control-label" for="body">Body</label>
		<div class="controls">
			<textarea id="rte" class="wysihtml5 input-xxlarge" name="body" rows="7"><?=$data['body']?></textarea>
		</div>
	</div>
	
	<div class="control-group">
		<label class="control-label" for="specimage">Image</label>
		<div class="controls row">
			<div class="span3"><img class="pull-left" id="specimage" src="<?=$image_path?>" /></div>
			<div class="span5">
			<input type="file" name="spec_image" value="" />
			<input type="button" class="btn btn-mini" value="Upload File" onclick="core.ui.uploadFrame(document.specialsForm,'uploadArea1','core.weeklySpecials.refreshImage({params});','app/weekly_specials/save_spec1');" />
			<input type="button" id="removeLogo" class="btn btn-mini btn-danger" value="Remove Image" onclick="core.doRequest('/weekly_specials/remove_logo',{'spec_id':<?=$data['spec_id']?>});" />

			<p class="alert alert-info help-block note">Note: images can not be larger than 400 pixels wide by 300 pixels tall. 
			For best results, use images that are exactly 400 pixels wide by 300 pixels tall.</p>
			<input type="hidden" name="placeholder_image" value="<?=$placeholder_image?>" />
			<iframe name="uploadArea1" id="uploadArea1" width="300" height="20" style="color:#fff;background-color:#fff;overflow:hidden;border:0;"></iframe>
			</div>
			
		</div>
	</div>

	<?if(lo3::is_market() && count($core->session['domains_by_orgtype_id'][2]) == 1){?>
	<input type="hidden" name="domain_id" value="<?=$data['domain_id']?>" />
	<?}?>
	<input type="hidden" name="spec_id" value="<?=$data['spec_id']?>" />
	<? save_buttons(); ?>
</form>
