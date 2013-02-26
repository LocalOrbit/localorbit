<?php
core::ensure_navstate(array('left'=>'left_dashboard'),'products-list','products-delivery');
core::head('Choose category','');
core_ui::fullWidth();
lo3::require_permission();
core_ui::load_library('js','product.js');
$this->request_rules()->js();
$this->cat_request_rules()->js();

#$final_cats = $this->get_final_cats();
#core::js('core.finalCats='.json_encode($final_cats).';');
$cats = core::model('categories')->collection()->filter('parent_id','is not null',true)->sort('cat_name')->to_array();
#echo('var mycats = '.json_encode($cats).';');
core::js('core.allCats='.json_encode($cats).';');

page_header('Choose a Category','#!products-list','Cancel','cancel');

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
	<div class="row">
		<div class="span12">
		<? if(!lo3::is_customer()){?>
		<?=core_form::input_select(
			'Seller',
			'org_id',
			null,
			$sellers,
			array(
				'default_show'=>true,
				'default_text'=>'Choose a seller',
				'text_column'=>'full_org_name',
				'value_column'=>'org_id',
			
			)
		)?>
		<!--<div class="error" id="select_org_msg" style="display: none;">Please select an organization.</div>-->
		<?}?>
		</div>
	</div>
	<div class="row">
		<? for($i=1;$i<7;$i++){?>
		<div class="span3" id="cat_col<?=$i?>"<?=(($i>1)?' style="display: none;"':'')?>>
			<select name="cats<?=$i?>" id="cats<?=$i?>" multiple="multiple" class="col_selector" onchange="product.selectCat(<?=$i?>,this.options[this.selectedIndex].value);" style="width: 200px !important;"></select>
		</div>
		<?}?>
		<div class="span2" id="picker_button">
			<input type="hidden" name="category_ids" value="" />
			<input type="button" class="btn btn-primary" style="display:none;" onclick="core.createProduct(document.catform,document.catform.category_ids.value);" value="add product" id="add_product" />
		</div>
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
