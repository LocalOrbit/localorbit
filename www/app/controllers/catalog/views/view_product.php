<?php

core::head('View a product','View a product.');
lo3::require_permission();
lo3::user_can_shop();


# get a list of their products
$catalog = core::model('products')->get_final_catalog(null,null,$core->data['prod_id']);
$dd_ids = explode(',',$catalog['products'][0]['dd_ids']);
$img = core::model('products');
$img['prod_id'] = $catalog['products'][0]['prod_id'];
$img = $img->get_image();

if (count($catalog['products']) <= 0) {
?>
<div class="error">This product is not currently available for ordering.</div>
<?
} else {
core_ui::load_library('js','catalog.js');
core::js('core.lo4.initRemoveSigns();');

core::ensure_navstate(array('left'=>'left_empty'));
core::write_navstate();
core_ui::load_library('js','catalog.js');
?>
<div class="row">
	<div class="span6">


		<h3 class="product_name notcaps" style="margin-bottom: 0;"><?=$catalog['products'][0]['name']?></h3>
		<small>Produced by <a href="#!sellers-oursellers--org_id-<?=$catalog['products'][0]['org_id']?>"><?=$catalog['products'][0]['org_name']?></a></small>

		<hr>
		<p class="note">
		<?
			$cat_ids = explode(',',$catalog['products'][0]['category_ids']);
			array_shift($cat_ids);
			$categories = core::model('categories')
				->collection()
				->filter('cat_id','in',implode(',',$cat_ids))
				->to_hash('cat_id');
			
			#print_r($catalog['categories']);
			#print_r($cats);
			for($i=0;$i<count($cat_ids);$i++)
			{
				if($i > 0)
					echo(' : ');
				echo($categories[$cat_ids[$i]][0]['cat_name']);
				
			}
			/*
			foreach ($categories as $category) {
				if ($first) {
					$first = false;
					continue;
				}
				if ($second) {
					$second = false;
				} else {
					echo ':';
				}
				?>
				<u><?=$category[0]['cat_name']?></u>
				<?
			}
			* */
		?>
		</p>


		<!--<p><strong>Who:</strong> <?=(($catalog['products'][0]['who']=='')?$catalog['sellers'][0]['profile']:$catalog['products'][0]['who'])?></p>-->
		<p><strong>What:</strong> <?=$catalog['products'][0]['description']?></p>
		<p><strong>How:</strong> <?=(($catalog['products'][0]['how']=='')?$catalog['sellers'][0]['product_how']:$catalog['products'][0]['how'])?></p>
		<hr />

		<h3 style="margin-bottom: 0;"><a href="#!sellers-oursellers--org_id-<?=$catalog['products'][0]['org_id']?>"><?=$catalog['products'][0]['org_name']?></a></h3>
		<small><?=$catalog['products'][0]['address']?>, <?=$catalog['products'][0]['city']?>, <?=$catalog['products'][0]['code']?></small>
		<?
		$addr = $catalog['products'][0]['address'].', '.$catalog['products'][0]['city'].', '.$catalog['products'][0]['code'].', '.$catalog['products'][0]['postal_code'];
		echo(core_ui::map('prodmap','100%','400px',8));
		core_ui::map_center('prodmap',$addr);
		core_ui::map_add_point('prodmap',$addr,'<h1>'.$catalog['products'][0]['org_name'].'</h1>'.$addr);
		}
		?>


	</div>

	<div class="span3">
		<?if($img){?>
			<img class="homepage" src="/img/products/cache/<?=$img['pimg_id']?>.<?=$img['width']?>.<?=$img['height']?>.300.300.<?=$img['extension']?>" />
		<?}else{?>
			<img src="<?=image('product_placeholder')?>" />
		<?}?>
		<hr />
		<form  id="product_<?=$catalog['products'][0]['prod_id']?>" name="prodForm" class="form-inline">

			<h4>Pricing</h4>
			<ol class="priceList">
			<?
			$this->render_product_pricing(
				$catalog['prices'][$catalog['products'][0]['prod_id']]
			);
			?>
			</ol>
			<hr />
			<h4>Add To Cart</h4>
				<div id="product_<?=$catalog['products'][0]['prod_id']?>">
				<?
				#echo('<pre>');
				#print_r($catalog['item_hash']);
				#echo('</pre>');
				$this->render_qty_delivery(
					$catalog['products'][0],
					$catalog['days'],
					$catalog['item_hash'][$catalog['products'][0]['prod_id']][0]['dd_id'],
					$dd_ids,
					$catalog['item_hash'][$catalog['products'][0]['prod_id']][0]['qty_ordered'],
					$catalog['item_hash'][$catalog['products'][0]['prod_id']][0]['row_total'],
					$catalog['addresses']
				); 
				?>
				</div>
				<div class="row">
					<div class="span3 pull-right alertContainer">
						<div class="alert prod_<?=$catalog['products'][0]['prod_id']?>_min_qty" style="display: none;"><button type="button" class="close" data-dismiss="alert">&times;</button><small></small></div>
					</div>
				</div>
		
			<!-- 
$prod,
				$days,
				$dd_id,
				$dd_ids,
				$qty,
				$total,
				$addresses
			<div class="error">This product is not currently available for ordering.</div>-->
			
		</form>
		<a href="#!catalog-shop" class="btn btn-info btn-block"> Continue Shopping</a>
		<!--

		<h4>Other Products from this Seller</h4>
		[FIX: Add other products]

		<h4>Other Products from this Category</h4>
		[FIX: Add other products]
		-->
	</div>
</div>