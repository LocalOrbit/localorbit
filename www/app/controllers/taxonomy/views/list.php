<?php

#mike - the idea here is to reuse the code you wrote for flyouts for selecting categories for a new product to allow admins only(!) 
# to select a category and then choose either the modify/delete or add new buttons below the flyouts.
# ADD: upon selecting the add new button, we would take them to a form where it shows the name of their selected category and has a text entry field for the new category name.
# I want to take them to this page rather than doing it on a popup or inline so that they have to verify they selected the correct category. 
# MODIFY/DELETE: upon selecting the modify/delete button, we would take them to a form which shows a top section of category actions: rename, move to a different parent, delete. 
# and below that a list of all products associated with that category.
# if there are no products, then allow them to choose a "delete this category" option and do the voodoo.
# if there are no products, then allow them to choose a "move to a different parent"
# if there are products, then tell them they must move each of the products to a new category (maybe we give them an option to move all at once)
# if there are products, then give options for each product line: "move" or "delete"
#      if "move" is chosen, then show yet another set of category selector flyouts with action button "move the product to this category"
#      if "delete" is chosen, then "archive" the product
# ARCHIVE: For each product in the "products" table, add a column for Archived flag. When a product has archived=true, it should not show in the catalog, our sellers, seller product tables, or any pulldowns. 
# It *should* still show up in orders, order history, product links from orders (although with no fields to buy more), delivery tools, and other places where it is not available for sale.

core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Product Taxonomy','This page is used to view and edit the product taxonomy');
lo3::require_permission();

#mike - will the product.js library cover us?
core_ui::load_library('js','product.js');
$this->request_rules()->js();

#oldcomment  $final_cats = $this->get_final_cats();
#oldcomment  core::js('core.finalCats='.json_encode($final_cats).';');
$cats = core::model('categories')->collection()->filter('parent_id','is not null',true)->sort('cat_name')->to_array();
#echo('var mycats = '.json_encode($cats).';');
core::js('core.allCats='.json_encode($cats).';');

lo3::require_orgtype('admin');

page_header('Choose a category','#!products-list','Cancel');

#if($core->session['orgtype_id'] != 3)
#{
#	$sellers = core::model('organizations')
#		->autojoin(
#			'left',
#			'domains',
#			'(organizations.domain_id=domains.domain_id)',
#			array('domains.name as domain_name')
#		)
#		->collection()
#		->filter('allow_sell',1)
#		->sort('organizations.name')
#		->sort('domains.name');
#	if($core->session['orgtype_id'] == 2)
#	{
#		$sellers->filter('organizations.domain_id','in',$core->session['domains_by_orgtype_id'][2]);
#	}
#}
	
?>
	<div id="becareful">
	Please be careful to select the <b>parent</b> category of your desired new category!!
	</div>
<form name="catform" action="products/request_new" onsubmit="return core.submit('/products/request_new',this);">
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
		<input type="button" class="button_primary" style="display:none;" onclick="core.deleteCategory(document.catform,document.catform.category_ids.value);" value="modify/delete this category" id="delete_category" />

		<input type="button" class="button_primary" style="display:none;" onclick="core.createNewcategory(document.catform,document.catform.category_ids.value);" value="add new category to this parent cateogry" id="add_newcategory" />
	</div>
	<?
	core::js('window.setTimeout(\'core.productInitCols();\',500);');
	?>
	<input type="hidden" name="is_testing" value="<?=(($core->config['stage'] == 'testing')?1:0)?>" />
</form>
<?foreach($final_cats as $final){?>
	<div class="prodcreate_category" id="cat_<?=$final['cat_id']?>" onclick="core.createProduct(document.catform,'<?=$final['category_ids']?>');">
		<?=$final['name']?>
	</div>
<?}?>
