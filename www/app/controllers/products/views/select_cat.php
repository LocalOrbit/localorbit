<?php
core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Choose category','');
lo3::require_permission();
core_ui::load_library('js','product.js');
$this->request_rules()->js();
$this->cat_request_rules()->js();

#$final_cats = $this->get_final_cats();
#core::js('core.finalCats='.json_encode($final_cats).';');
$cats = core::model('categories')->collection()->filter('parent_id','is not null',true)->sort('cat_name')->to_array();
#echo('var mycats = '.json_encode($cats).';');
core::js('core.allCats='.json_encode($cats).';');

page_header('Choose a category','#!products-list','Cancel');

if(!lo3::is_customer())
{
	$sellers = core::model('organizations')		
		->collection()
		->filter('allow_sell',1)
		->sort('organizations.name')
		->sort('domains.name');
	if(lo3::is_market())
	{
		$sellers->filter('domains.domain_id','in',$core->session['domains_by_orgtype_id'][2]);
	}
}
	
?>
<form name="catform" action="products/request_new" onsubmit="return core.submit('/products/request_new',this);">
	<table class="form">
		<? if(!lo3::is_customer()){?>
		<tr>
			<td class="label">Seller</td>
			<td class="value">
				<select name="org_id" style="width: 400px;">
					<option value="">Choose a seller</option>
					<?foreach($sellers as $seller){?>
					<option value="<?=$seller['org_id']?>"><?=$seller['full_org_name']?></option>
					<?}?>
				</select>
				<div class="error" id="select_org_msg" style="display: none;">Please select an organization.</div>
			</td>
		</tr>
		<?}?>
	</table>
	<table style="width:520px;" id="picker_cols">
		<col width="260" />
		<col width="260" />
		<col width="260" />
		<col width="260" />
		<col width="260" />
		<col width="260" />
		<col width="260" />
		<col width="260" />
		<col width="260" />
		<tr>
			<td id="cat_col1" class="col_selector"><select name="cats1" id="cats1" multiple="multiple" class="col_selector" onchange="product.selectCat(1,this.options[this.selectedIndex].value);"></select></td>
			<td id="cat_col2" class="col_selector"><select name="cats2" id="cats2" multiple="multiple" class="col_selector" onchange="product.selectCat(2,this.options[this.selectedIndex].value);"></select></td>
			<td id="cat_col3" class="col_selector"><select name="cats3" id="cats3" multiple="multiple" class="col_selector" onchange="product.selectCat(3,this.options[this.selectedIndex].value);"></select></td>
			<td id="cat_col4" class="col_selector"><select name="cats4" id="cats4" multiple="multiple" class="col_selector" onchange="product.selectCat(4,this.options[this.selectedIndex].value);"></select></td>
			<td id="cat_col5" class="col_selector"><select name="cats5" id="cats5" multiple="multiple" class="col_selector" onchange="product.selectCat(5,this.options[this.selectedIndex].value);"></select></td>
			<td id="cat_col6" class="col_selector"><select name="cats6" id="cats6" multiple="multiple" class="col_selector" onchange="product.selectCat(6,this.options[this.selectedIndex].value);"></select></td>
			<td id="cat_col7" class="col_selector"><select name="cats7" id="cats7" multiple="multiple" class="col_selector" onchange="product.selectCat(7,this.options[this.selectedIndex].value);"></select></td>
			<td id="cat_col8" class="col_selector"><select name="cats8" id="cats8" multiple="multiple" class="col_selector" onchange="product.selectCat(8,this.options[this.selectedIndex].value);"></select></td>
			<td id="cat_col9" class="col_selector"><select name="cats9" id="cats9" multiple="multiple" class="col_selector" onchange="product.selectCat(9,this.options[this.selectedIndex].value);"></select></td>
		</tr>
	</table>
	<div style="clear:both;text-align:right;" id="picker_button">
		<br />		
		<input type="hidden" name="category_ids" value="" />
		<input type="button" class="button_primary" style="display:none;" onclick="core.createProduct(document.catform,document.catform.category_ids.value);" value="add product" id="add_product" />
	</div>
	<div id="newProdRequestLink">
	Don't see what you're looking for? <a href="#!products-select_cat" onclick="$('#newProdRequestLink,#newProdRequest,#picker_button,#picker_cols').toggle();">Click here</a> to request a new product category
	</div>
	<fieldset id="newProdRequest" style="display: none;padding: 10px; width: 340px;">
		<h2>Add new product category</h2>
		Adding new product categories to the system requires approval. Please enter the product category you'd like to have added. We'll have it added for you within 
		24 hours.
		<table class="form">
			<tr>
				<td class="label">Product</td>
				<td class="value"><input type="text" name="product_request" value="" /></td>
			</tr>
		</table>
		<div class="buttonset">
			<input type="button" class="button_secondary" onclick="$('#newProdRequestLink,#newProdRequest,#picker_button,#picker_cols').toggle();" value="cancel" />
			<input type="button" class="button_secondary" onclick="product.requestNewProduct();" value="request product" />
		</div>
	</fieldset>
	
	<?
	core::js('window.setTimeout(\'core.productInitCols();\',500);');
	?>
	<input type="hidden" name="is_testing" value="<?=(($core->config['stage'] == 'testing')?1:0)?>" />
</form>
<? if (lo3::is_admin()){?>
<form name="catRequest">
	<div id="newCategorySetLink">
	Admins: <a href="#!products-select_cat" onclick="$('#newCategorySetLink,#newProdCategory,#picker_button,#picker_cols').toggle();">Click here</a> to add a new product category
	</div>
	<fieldset id="newProdCategory" style="display: none;padding: 10px; width: 340px;">
		<h2>Add new product category</h2>
		Please be careful - there is not an easy way to fix spelling or move categories around. Please enter the parent category number (look on the product selecter on testing to see numbers) and the name of the new category below. To create a root level category, please use parent 2. 
		<table class="form">
			<tr>
				<td class="label">Parent Category Number</td>
				<td class="value"><input type="text" id="parent_category" name="parent_category" value="" /></td>
			</tr>
			<tr>
				<td class="label">New Category Name</td>
				<td class="value"><input type="text" id="new_category" name="new_category" value="" /></td>
			</tr>
		</table>
		<div class="buttonset">
			<input type="button" class="button_secondary" onclick="$('#newCategorySetLink,#newProdCategory,#picker_button,#picker_cols').toggle();" value="cancel" />
			<input type="button" class="button_secondary" onclick="product.requestNewCategory();" value="create category" />
		</div>
	</fieldset>
</form>
<?}?>
<?foreach($final_cats as $final){?>
	<div class="prodcreate_category" id="cat_<?=$final['cat_id']?>" onclick="core.createProduct(document.catform,'<?=$final['category_ids']?>');">
		<?=$final['name']?>
	</div>
<?}?>
