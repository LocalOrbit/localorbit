<?
function get_total_qty ($total, $item) {
	$total += $item[0]['qty_ordered'];
	return $total;
}
$cart = core::model('lo_order')->get_cart();
$cart->load_items();
$item_hash = $cart->items->to_hash('prod_id');
$totalQty = count($item_hash);
$cart_count = 0;
?>
<script type="text/javascript" charset="utf-8">
$(function()
	{
		// Call stylesheet init so that all stylesheet changing functions
		// will work.
		$.stylesheetInit();

		// This code loops through the stylesheets when you click the link with
		// an ID of "toggler" below.
		$('#toggler').bind(
			'click',
			function(e)
			{
				$.stylesheetToggle();
				return false;
			}
		);

		// When one of the styleswitch links is clicked then switch the stylesheet to
		// the one matching the value of that links rel attribute.
		$('.styleswitch').bind(
			'click',
			function(e)
			{
				$.stylesheetSwitch(this.getAttribute('rel'));
				return false;
			}
		);
	}
);
</script>
<!--
<?if($core->config['stage'] != 'production'){?>
<p class="navbar-text pull-left">
	<small>Style Switcher (Temporary):</small>
</p>
<ul class="nav pull-left">

	<li><a href="#" rel="styles1" class="styleswitch"><small>1</small></a></li>
	<li><a href="#" rel="styles2" class="styleswitch"><small>2</small></a></li>
	<li><a href="#" rel="styles3" class="styleswitch"><small>3</small></a></li>

</ul>
<?}?>
-->
<ul class="nav pull-right">
	<li class="divider-vertical"></li>

	<?if(lo3::is_admin() || lo3::is_market() || lo3::is_seller()): ?>
		<li>
			<a id="dashboard-home" href="<?=$core->config['app_page']?>#!dashboard-home" onclick="core.go(this.href);" class="main"><?=$core->i18n['nav1:dashboard']?></a>
		</li>
	<? else: ?>
		<li>
			<a id="dashboard-home" href="<?=$core->config['app_page']?>#!orders-purchase_history" onclick="core.go(this.href);" class="main"><?=$core->i18n['nav1:dashboard']?></a>
		</li>
	<!--	<li class="dropdown">
			<a class="dropdown-toggle" data-toggle="dropdown" href="">Your Account</a>
			<ul class="dropdown-menu">
				<?if($core->session['is_active'] == 1 && $core->session['org_is_active'] == 1){?>
				<li><a href="#!orders-purchase_history" onclick="core.go(this.href);">Purchase History</a></li>
					<? if(!lo3::is_seller()){?>
					<li><a href="#!products-request" onclick="core.go(this.href);">Suggest A New Product</a></li>
					<?}?>
				<?}?>
				<li><a href="#!users-edit--entity_id-<?=$core->session['user_id']?>-me-1" onclick="core.go(this.href);">Update Profile</a></li>
				<li><a href="#!organizations-edit--org_id-<?=$core->session['org_id']?>-me-1" onclick="core.go(this.href);">Update Organization</a></li>
				<?if(lo3::is_customer() && !lo3::is_seller()){?>
				<li><a href="#!reports-edit" onclick="core.go(this.href);">Reports</a></li>
				<?}?>
				<li><a href="#!users-change_password" onclick="core.go(this.href);">Change Your Password</a></li>
				<li><a href="#!payments-home" onclick="core.go(this.href);">Financials</a></li>
			</ul>
		</li>-->
	<? endif; ?>

	<li class="divider-vertical"></li>
	<li class="dropdown">
		<input type="hidden" id="emptyCart" value="<?=($totalQty<=0)?>"/>
		<a id="yourCartDropDown" class="dropdown-toggle" data-toggle="dropdown" href=""><i class="icon-cart icon-white"></i> Your Cart <span class="badge" id="totalQty"><?=$totalQty?></span></a>
		<div class="dropdown-menu span4 yourCart">
			<?
		foreach ($item_hash as $prod_id => $item) {
			$cart_count++;
			$prod = core::model('products')->load($item[0]['prod_id']);
			?>
			<div class="row">
				<span class="span1 product-image">
					<? if(intval($prod['pimg_id']) > 0){?>
					<img class="img-polaroid catalog" src="/img/products/cache/<?=$prod['pimg_id']?>.<?=$prod['width']?>.<?=$prod['height']?>.100.75.<?=$prod['extension']?>" />
					<?}else{?>
					<img class="img-polaroid catalog_placeholder" src="<?=image('product_placeholder_small')?>" />
					<?}?>
				</span>
				<span class="span2">
					<div class="productName"><?=$item[0]['product_name']?></div>
					<div>Quantity: <?=$item[0]['qty_ordered']?> <?=(($item[0]['qty_ordered']>1)?$item[0]['unit_plural']:$item[0]['unit'])?></div>
				</span>
			</div>
			<?
		}
		?>
			<div class="row">
				<span class="span4">
					<? if($cart_count == 0){?>
						You do not have any items in your cart.
						<a class="btn btn-primary btn-block" href="#!catalog-shop">Shop Now</a>

					<?}else{?>
					<span class="pull-left" style="padding-top: 8px;"><strong>Subtotal: <?=core_format::price($cart['grand_total'])?></strong></span>
					<span class="pull-right">
						<a class="btn btn-info btn-small" href="#!catalog-shop--cart-yes">Modify your cart</a>
						<a class="btn btn-primary btn-small" href="#!catalog-checkout">Check out</a>
					</span>
					<?}?>
					<!--
					<a class="btn btn-block btn-warning" href="#!catalog-your_cart">
						<span class="viewCart pull-left">View Cart</span>
						&nbsp;
						<span class="pull-right">Subtotal: <?=core_format::price($cart['grand_total'])?></span>
					</a>
					-->
				</span>
			</div>
		</div>
	</li>
	<li class="divider-vertical"></li>
	<li><a href="http://myaccount.zendesk.com/account/dropboxes/20147973" onClick="script: Zenbox.show(); return false;">Help</a></li>
	<li class="divider-vertical"></li>
	<li><a id="auth-logout" href="<?=$core->config['app_page']?>#!auth-logout" onclick="core.go(this.href);"><?=$core->i18n['nav1:logout']?></a></li>
</ul>
<p class="navbar-text pull-right">
	<?=$core->i18n['greeting']?> <?=$core->session['first_name']?>
</p>

<ul class="nav pull-left">
	<li>
		<a style="line-height: normal; padding: 12px; font-size: 10px" href="http://<?=$core->config['hostname_prefix']?><?=$core->config['default_hostname']?>">
			<strong>Powered by Local Orbit</strong><br/>
		</a>
	</li>
</ul>
<? core::replace('nav1top');?>
<li>
	<a id="catalog-shop" href="<?=$core->config['app_page']?>#!catalog-shop" onclick="core.go(this.href);" class="main">
		<span id="catalog-shop" class="nav-actual"><?=$core->i18n['nav1:shop']?></span>
		<span class="nav-sec">See what's fresh</span>
	</a>
</li>
<li>
	<a id="sellers-oursellers" href="<?=$core->config['app_page']?>#!sellers-oursellers" onclick="core.go(this.href);" class="main">
		<span class="nav-actual">Sellers</span>
		<span class="nav-sec">See what's fresh</span>
	</a>
</li>
<li>
	<a id="market-info" href="<?=$core->config['app_page']?>#!market-info" onclick="core.go(this.href);" class="main">
		<span class="nav-actual"><?=$core->i18n['nav1:marketinfo']?></span>
		<span class="nav-sec">About us and our sellers</span>
	</a>
</li>
<li class="last">
	<a id="news-list" href="<?=$core->config['app_page']?>#!news-list">
		<span class="nav-actual">News</span>
		<span class="nav-sec">Latest from our market</span>
	</a>
</li>

<? core::replace('mainnav');?>
