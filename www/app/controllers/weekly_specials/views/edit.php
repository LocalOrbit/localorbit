<?php

core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Buy and Sell Local Food on Local Orbit - Edit Weekly Specials','This page is used to edit Weekly Specials');
lo3::require_permission();
lo3::require_login();
core_ui::load_library('js','weeklySpecials.js');

core_ui::tabset('specialstabs');
core_ui::rte();

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


page_header('Editing '.$data['name'],'#!weekly_specials-list','cancel');
?>

<form name="specialsForm" method="post" action="/weekly_specials/update" onsubmit="return core.submit('/weekly_specials/update',this);" enctype="multipart/form-data">
	<div class="tabset" id="specialstabs">
		<div class="tabswitch" id="specialstabs-s1">
			Featured Deal
		</div>
	</div>
	<div class="tabarea" id="specialstabs-a1">
		<div id="deactivate"<?=(($data['is_active'] == 1)?'':' style="display:none;"')?>>
			This is currently the active featured deal. If you would like to deactivate this deal, 			
			<a href="Javascript:$('#activate,#deactivate').toggle();core.doRequest('/weekly_specials/toggle_special',{'domain_id':<?=$data['domain_id']?>,'spec_id':<?=$data['spec_id']?>});">click here.</a>
		</div>
		<div id="activate"<?=(($data['is_active'] == 1)?' style="display:none;"':'')?>>
			This is NOT the active featured deal. If you would like to make this special the active deal, 
			<a href="Javascript:$('#activate,#deactivate').toggle();core.doRequest('/weekly_specials/toggle_special',{'domain_id':<?=$data['domain_id']?>,'spec_id':<?=$data['spec_id']?>});">click here.</a>
		</div>
		<br />
		<table class="form">
			<?if(lo3::is_admin() || count($core->session['domains_by_orgtype_id'][2])>1){?>
			<tr>
				<td class="label">Hub</td>
				<td class="value">
					<select name="domain_id" onchange="core.lo3.getUpdatedDataForSelector('get_products',this.options[this.selectedIndex].value,document.specialsForm.product_id,'Select a product');">
						<option value="0">Select a hub</option>
						<?=core_ui::options($hubs,$data['domain_id'],'domain_id','name')?>
					</select>
				</td>
			</tr>
			<?}?>
			<tr>
				<td class="label">Name</td>
				<td class="value"><input type="text" name="name" value="<?=$data['name']?>" /></td>
			</tr>
			<tr>
				<td class="label">Product</td>
				<td class="value">
					<select name="product_id" style="width: 500px;">
						<option value="0">Select a product</option>
						<?=core_ui::options($products,$data['product_id'],'prod_id','product_name')?>
					</select>
				</td>
			</tr>
			<tr>
				<td class="label">Title</td>
				<td class="value"><input type="text" name="title" value="<?=$data['title']?>" /></td>
			</tr>
			<tr>
				<td class="label">Body</td>
				<td class="value"><textarea id="rte" class="rte" name="body" rows="7" cols="73"><?=$data['body']?></textarea></td>
			</tr>
			<tr>
				<td class="label">Image</td>
				<td class="value">
					<img id="specimage" src="<?=$image_path?>" />
					<br />
					<input type="file" name="spec_image" value="" />
					<input type="button" class="button_secondary" value="Upload" onclick="core.ui.uploadFrame(document.specialsForm,'uploadArea1','core.weeklySpecials.refreshImage({params});','app/weekly_specials/save_spec1');" />&nbsp;&nbsp;
					<input type="button" id="removeLogo" class="button_secondary" value="Remove Image" onclick="core.doRequest('/weekly_specials/remove_logo',{'spec_id':<?=$data['spec_id']?>});" />
					<br />
					Note: images can not be larger than 400 pixels wide by 300 pixels tall.<br />
					For best results, use images that are exactly 400 pixels wide by 300 pixels tall.
					<input type="hidden" name="placeholder_image" value="<?=$placeholder_image?>" />
					<iframe name="uploadArea1" id="uploadArea1" width="300" height="20" style="color:#fff;background-color:#fff;overflow:hidden;"></iframe>
				</td>
			</tr>	
		</table>
	</div>
	<?if(lo3::is_market() && count($core->session['domains_by_orgtype_id'][2]) == 1){?>
	<input type="hidden" name="domain_id" value="<?=$data['domain_id']?>" />
	<?}?>
	<input type="hidden" name="spec_id" value="<?=$data['spec_id']?>" />
	<? save_buttons(); ?>
</form>
