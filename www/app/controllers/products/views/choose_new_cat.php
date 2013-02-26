<?php
core::ensure_navstate(array('left'=>'left_dashboard'),'products-list','products-delivery');
core::head('Choose category','');
lo3::require_permission();
core_ui::load_library('js','product.js');


$final_cats = $this->get_final_cats();
core::js('core.finalCats='.json_encode($final_cats).';');
page_header('Choose a category','#!products-list','Back to products');

if($core->session['orgtype_id'] != 3)
{
	$sellers = core::model('organizations')
		->autojoin(
			'left',
			'domains',
			'(organizations.domain_id=domains.domain_id)',
			array('domains.name as domain_name')
		)
		->collection()
		->filter('allow_sell',1)
		->sort('organizations.name')
		->sort('domains.name');
}
	
?>
<form name="catform" action="products/edit" onsubmit="return core.submit('/products/edit',this);">
	<table class="form">
		<? if($core->session['orgtype_id'] != 3){?>
		<tr>
			<td class="label">Seller</td>
			<td class="value">
				<select name="org_id" style="width: 400px;">
					<option value="">Choose a seller</option>
					<?foreach($sellers as $seller){?>
					<option value="<?=$seller['org_id']?>"><?=$seller['domain_name']?> - <?=$seller['name']?></option>
					<?}?>
				</select>
			</td>
		</tr>
		<?}?>
		<tr>
			<td class="label">Search</td>
			<td class="value"><input type="text" name="product" value="" onkeyup="core.handleCatSearch(this.value);" /></td>
		</tr>
	</table>
	
	<input type="hidden" name="category_ids" value="" />
</form>
<div id="no_prods_msg" style="display: none;">
	No products matched your search. If you cannot find a suitable product on our current list, please <a href="#!products-request" onclick="core.go(this.href);">suggest a product</a>.
</div>
<?foreach($final_cats as $final){?>
	<div class="prodcreate_category" id="cat_<?=$final['cat_id']?>" onclick="core.createProduct(document.catform,'<?=$final['category_ids']?>');">
		<?=$final['name']?>
	</div>
<?}?>
