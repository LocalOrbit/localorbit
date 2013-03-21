<?
# the parameters for views called as functions are stored in $core->view.
global $core,$prods,$prices,$delivs;
$prod    = $core->view[0];
$cats    = $core->view[1];
$seller  = $core->view[2];
$pricing = $core->view[3];
$delivs  = $core->view[4];
$style1  = $core->view[5];
$style2  = $core->view[6];
$qty     = $core->view[7];
$total   = $core->view[8];
$days 	 = $core->view[9];
$dd_id 	 = $core->view[10];
$addresses = $core->view[11];


# remove this code
#$first_period = strpos($description,'.');
#$first_exclam = strpos($description,'!');
#$index = ($first_period < $first_exclam)?$first_period:$first_exclam;
#$description = substr($description,0,$index+1);

#$farm_name = substr($prod['org_name'],0,20);
#$farm_name .= (strlen($prod['org_name'])>=20)?'&hellip;':'';


# format the total a bit
$total =floatval($total) ;
# modify the prod data slightly to make rendering easier
$prod['category_ids'] = explode(',',$prod['category_ids']);
$dd_ids = explode(',',$prod['dd_ids']);
$dds = array();
foreach($dd_ids as $dd_id_key)
{
	$dds[] = $delivs[$dd_id_key][0];
}
$rendered_prices = 0;
?>
<div class="row">
	<div id="product_<?=$prod['prod_id']?>" class="product-row">
		<div class="span9">
			<div class="row">
				<div class="span1 product-image">
					<? if(intval($prod['pimg_id']) > 0){?>
					<img class="img-rounded catalog" src="/img/products/cache/<?=$prod['pimg_id']?>.<?=$prod['width']?>.<?=$prod['height']?>.100.75.<?=$prod['extension']?>" />
					<?}else{?>
					<img class="img-rounded catalog_placeholder" src="<?=image('product_placeholder_small')?>" />
					<?}?>
				</div>

				<div class="span4 product-info">
					<? $this->render_product_description($prod,$seller); ?>
				</div>

				<div class="span4">
					<div class="row">
						<ol class="span2 priceList">
							<? $this->render_product_pricing($pricing, $prod); ?>
						</ol>

						<div class="span2">
							<? $this->render_qty_delivery($prod,$days,$dd_id,$dd_ids,$qty,$total,$addresses); ?>
						</div>
					</div>
					<div class="row">
						<div class="span3 pull-right alertContainer">
							<div class="alert prod_<?=$prod['prod_id']?>_min_qty" style="display: none;"><button type="button" class="close" data-dismiss="alert">&times;</button><small></small></div>
						</div>
					</div>
				</div>
			</div>
			<div class="row">
				<hr class="span9" />
			</div>
		</div>
	</div> <!-- /.product-row-->

</div> <!-- /.row-->