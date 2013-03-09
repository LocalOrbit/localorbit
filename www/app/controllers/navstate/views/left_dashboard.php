<div class="navbar navbar-static-top">
	<div class="navbar-inner">

		<!-- .btn-navbar is used as the toggle for collapsed navbar content -->
		<a class="btn btn-navbar" data-toggle="collapse" data-target="#dashnav">
			<span class="icon-bar"></span>
			<span class="icon-bar"></span>
			<span class="icon-bar"></span>
		</a>

		<!--<small class="brand visible-phone">Administration</small>-->

		<div id="dashnav" class="nav-collapse collapse">
		<? if(lo3::is_admin()){?>

		<ul class="nav">
			<li class="dropdown">
				<a id="market-admin" href="#" class="dropdown-toggle" data-toggle="dropdown">
					<i class="icon-wand icon-large"></i>
					<?=$core->i18n['nav2:marketadmin']?>
					<b class="caret"></b>
				</a>
				<ul class="dropdown-menu">
					<li><a id="market-list" href="#!market-list" onclick="core.go(this.href);"><i class="icon-home"></i>Markets</a></li>
					<li><a id="organizations-list" href="#!organizations-list" onclick="core.go(this.href);"><i class="icon-grid"></i><?=$core->i18n['nav2:marketadmin:organizations']?></a></li>
					<li><a id="users-list" href="#!users-list" onclick="core.go(this.href);"><i class="icon-users"></i><?=$core->i18n['nav2:marketadmin:users']?></a></li>
					<li><a id="events-list" href="#!events-list" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:usereventlog']?></a></li>
					<li><a id="dictionaries-edit" href="#!dictionaries-edit" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:dictionary']?></a></li>
					<li><a href="https://us1.admin.mailchimp.com/campaigns/">Mailchimp Statistics</a></li>
				</ul>
			</li>
		</ul>

		<ul class="nav"><li><a id="payments-demo" href="#!payments-demo" onclick="core.go(this.href);"><i class="icon-coins  icon-large"></i>Financials</a></li></ul>
		
		
		<ul class="nav">
			<li class="dropdown">
				<a id="products-delivery" href="#" class="dropdown-toggle" data-toggle="dropdown">
					<i class="icon-signup icon-large"></i>
					Products & Delivery
					<b class="caret"></b>
				</a>
				<ul class="dropdown-menu">
					<li><a id="orders-list" href="#!orders-list" onclick="core.go(this.href);"><i class="icon-clipboard"></i><?=$core->i18n['nav2:marketadmin:orders']?></a></li>
					<li><a id="sold_items-list" href="#!sold_items-list" onclick="core.go(this.href);"><i class="icon-stack-checkmark"></i><?=$core->i18n['nav2:marketadmin:sold_items']?></a></li>
					<li><a id="products-list" href="#!products-list" onclick="core.go(this.href);"><i class="icon-apple-fruit"></i><?=$core->i18n['nav2:marketadmin:products']?></a></li>
					<li><a id="units-list" href="#!units-list" onclick="core.go(this.href);"><i class="icon-checkbox-unchecked "></i><?=$core->i18n['nav2:marketadmin:units']?></a></li>
				</ul>
			</li>
		</ul>

		<ul class="nav">
			<li class="dropdown">
				<a id="marketing" href="#" class="dropdown-toggle" data-toggle="dropdown">
					<i class="icon-qrcode icon-large"></i>
					Marketing
					<b class="caret"></b>
				</a>
				<ul class="dropdown-menu">
					<li><a id="fresh_sheet-review" href="#!fresh_sheet-review" onclick="core.go(this.href);"><i class="icon-list"></i><?=$core->i18n['nav2:marketadmin:freshsheet']?></a></li>
					<li><a id="newsletters-list" href="#!newsletters-list" onclick="core.go(this.href);"><i class="icon-profile"></i>Newsletters</a></li>
					<li><a id="market_news-list" href="#!market_news-list" onclick="core.go(this.href);"><i class="icon-newspaper"></i>Market News</a></li>
					<li><a id="weekly_specials-list" href="#!weekly_specials-list" onclick="core.go(this.href);"><i class="icon-star"></i>Featured Promotions</a></li>
					<li><a id="discount_codes-list" href="#!discount_codes-list" onclick="core.go(this.href);"><i class="icon-tag"></i>Discount Codes</a></li>
					<li><a id="delivery_tools-view" href="#!delivery_tools-view" onclick="core.go(this.href);"><i class="icon-truck"></i><?=$core->i18n['nav2:marketadmin:weeklysalesndeliveryinfo']?></a></li>
					<li><a id="sent_emails-list" href="#!sent_emails-list" onclick="core.go(this.href);"><i class="icon-mail-send"></i><?=$core->i18n['nav2:marketadmin:sentemails']?></a></li>
					<li><a id="emails-tests" href="#!emails-tests" onclick="core.go(this.href);"><i class="icon-envelop"></i><?=$core->i18n['nav2:emails:tests']?></a></li>
					<!--<li><a href="#!photos-list" onclick="core.go(this.href);">Photos</a></li>-->
				</ul>
			</li>
		</ul>
		<ul class="nav">
			<li class="dropdown">
				<a id="reports" href="#" class="dropdown-toggle" data-toggle="dropdown">
					<i class="icon-bars icon-large"></i>
					Reports
					<b class="caret"></b>
				</a>
				<ul class="dropdown-menu">
					<li><a id="reports-edit" href="#!reports-edit" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:reports']?></a></li>
					<li><a id="referrals-edit" href="#!referrals-list" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:referrals']?></a></li>
					<li><a id="metrics-overview" href="#!metrics-overview" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:metrics']?></a></li>
				</ul>
			</li>
		</ul>

		<!--<li><a href="#!taxonomy-list" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:producttaxonomy']?></a></li>-->
		<!--<li><a href="#!translations-list" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:translations']?></a></li>-->
		<!--<li><a href="#!customizations-list" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:customizations']?></a></li>-->
		<!--<li><a href="#!payments-list" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:payments']?></a></li>-->
		<!--<li><a href="#!admin_roles-list" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:adminroles']?></a></li>-->


		<?} # / is admin ?>

		<? if(lo3::is_market()){?>
		<ul class="nav">
			<li class="dropdown">
				<a id="market-admin" href="#" class="dropdown-toggle" data-toggle="dropdown">
					<i class="icon-wand icon-large"></i>
					<?=$core->i18n['nav2:marketadmin']?>
					<b class="caret"></b>
				</a>
				<ul class="dropdown-menu">
					<?if(count($core->session['domains_by_orgtype_id'][2]) > 1){?>
					<li><a id="market-list" href="#!market-list" onclick="core.go(this.href);"><i class="icon-home"></i>Markets</a></li>
					<?}else{?>
					<li><a id="market-edit" href="#!market-edit--domain_id-<?=$core->session['domains_by_orgtype_id'][2][0]?>" onclick="core.go(this.href);"><i class="icon-home"></i>Market</a></li>
					<?}?>
					<li><a id="organizations-list" href="#!organizations-list" onclick="core.go(this.href);"><i class="icon-grid"></i><?=$core->i18n['nav2:marketadmin:organizations']?></a></li>
					<li><a id="users-list" href="#!users-list" onclick="core.go(this.href);"><i class="icon-users"></i><?=$core->i18n['nav2:marketadmin:users']?></a></li>
				</ul>
			</li>
		</ul>
		<ul class="nav"><li><a id="payments-demo" href="#!payments-demo" onclick="core.go(this.href);"><i class="icon-coins  icon-large"></i>Financials</a></li></ul>
		<ul class="nav">
			<li class="dropdown">
				<a id="products-delivery" href="#" class="dropdown-toggle" data-toggle="dropdown">
					<i class="icon-signup icon-large"></i>
					Orders & Delivery
					<b class="caret"></b>
				</a>
				<ul class="dropdown-menu">
					<li><a id="delivery_tools-view" href="#!delivery_tools-view" onclick="core.go(this.href);"><i class="icon-truck"></i><?=$core->i18n['nav2:marketadmin:weeklysalesndeliveryinfo']?></a></li>
					<li><a id="orders-list" href="#!orders-list" onclick="core.go(this.href);"><i class="icon-clipboard"></i><?=$core->i18n['nav2:marketadmin:orders']?></a></li>
					<li><a id="sold_items-list" href="#!sold_items-list" onclick="core.go(this.href);"><i class="icon-stack-checkmark"></i><?=$core->i18n['nav2:marketadmin:sold_items']?></a></li>
				</ul>
			</li>
		</ul>
		
		<ul class="nav"><li><a id="products-list" href="#!products-list" onclick="core.go(this.href);"><i class="icon-apple-fruit"></i><?=$core->i18n['nav2:marketadmin:products']?></a></li></ul>
		<ul class="nav">
			<li class="dropdown">
				<a id="marketing" href="#" class="dropdown-toggle" data-toggle="dropdown">
					<i class="icon-bullhorn icon-large"></i>
					Marketing
					<b class="caret"></b>
				</a>
				<ul class="dropdown-menu">
					<li><a id="fresh_sheet-review" href="#!fresh_sheet-review" onclick="core.go(this.href);"><i class="icon-list"></i><?=$core->i18n['nav2:marketadmin:freshsheet']?></a></li>
					<li><a id="newsletters-list" href="#!newsletters-list" onclick="core.go(this.href);"><i class="icon-profile"></i>Newsletters</a></li>
					<li><a id="market_news-list" href="#!market_news-list" onclick="core.go(this.href);"><i class="icon-newspaper"></i>Market News</a></li>
					<li><a id="weekly_specials-list" href="#!weekly_specials-list" onclick="core.go(this.href);"><i class="icon-star"></i>Featured Promotions</a></li>
					<li><a id="discount_codes-list" href="#!discount_codes-list" onclick="core.go(this.href);"><i class="icon-tag"></i>Discount Codes</a></li>
					<!--<li><a href="#!photos-list" onclick="core.go(this.href);">Photos</a></li>-->
				</ul>
			</li>
		</ul>
		<ul class="nav"><li><a id="reports-edit" href="#!reports-edit" onclick="core.go(this.href);"><i class="icon-bars icon-large"></i> <?=$core->i18n['nav2:marketadmin:reports']?></a></li></ul>

		<?} # / is market manager ?>

		<? if(lo3::is_customer() && lo3::is_seller()){?>

		<ul class="nav">
			<li class="dropdown">
				<a id="sales-information" href="#" class="dropdown-toggle" data-toggle="dropdown">
					<i class="icon-coins icon-large"></i>
					Sales Information
					<b class="caret"></b>
				</a>
				<ul class="dropdown-menu">
					<li><a id="delivery_tools-view" href="#!delivery_tools-view" onclick="core.go(this.href);"><i class="icon-truck"></i>Upcoming Deliveries</a></li>
					<li><a id="orders-current_sales" href="#!orders-current_sales" onclick="core.go(this.href);"><i class="icon-signup"></i>Current Sales</a></li>
					<li><a id="reports-edit" href="#!reports-edit" onclick="core.go(this.href);"><i class="icon-bars"></i>Reports</a></li>
					<!-- <li><a href="#!orders-sales_report" onclick="core.go(this.href);">Sales History</a></li> -->
					<!-- <li><a href="#!payment_report-view" onclick="core.go(this.href);">Payment History</a></li> -->
				</ul>
			</li>
		</ul>
		<ul class="nav"><li><a id="payments-demo" href="#!payments-demo" onclick="core.go(this.href);"><i class="icon-coins  icon-large"></i>Financials</a></li></ul>
		<ul class="nav"><li><a id="products-list" href="#!products-list" onclick="core.go(this.href);"><i class="icon-apple-fruit icon-large"></i> Products</a></li></ul>

		<?} # / is customer or seller ?>
<?if(lo3::is_customer() && !lo3::is_seller()){?>
		<ul class="nav"><li><a id="orders-purchase_history" href="#!orders-purchase_history" onclick="core.go(this.href);"><i class="icon-cart-checkout"></i>Purchase History</a></li></ul>
						<?}?>
		<ul class="nav">
			<li class="dropdown">
				<a id="account" href="#" class="dropdown-toggle" data-toggle="dropdown">
					<i class="icon-address-book icon-large"></i>
					Account
					<b class="caret"></b>
				</a>
				<ul class="dropdown-menu">
					<!--<li><a href="#!payments-demo" onclick="core.go(this.href);">Financials</a></li>	-->
					<li><a id="users-edit-me" href="#!users-edit--entity_id-<?=$core->session['user_id']?>-me-1" onclick="core.go(this.href);"><i class="icon-user"></i>E-mail 	&amp; Password</a></li>
					<li><a id="organizations-edit-me" href="#!organizations-edit--org_id-<?=$core->session['org_id']?>-me-1" onclick="core.go(this.href);"><i class="icon-grid"></i>Your Organization</a></li>
					<?if($core->session['is_active'] == 1 && $core->session['org_is_active'] == 1){?>
						<?if(lo3::is_customer() && !lo3::is_seller()){?>
							<li><a id="reports-edit" href="#!reports-edit" onclick="core.go(this.href);"><i class="icon-bars"></i>Reports</a></li>
						<?}?>
					<?}?>
				</ul>
			</li>
		</ul>
		<? if(lo3::is_customer() && !lo3::is_seller()){1?>
			<ul class="nav"><li><a id="payments-demo" href="#!payments-demo" onclick="core.go(this.href);"><i class="icon-coins  icon-large"></i>Financials</a></li></ul>
		<?}?>
		</div> <!-- /.nav-collapse-->

	</div>
</div>
<? core::replace('dashboardnav'); ?>


<h2>Your Account</h2>
<ul class="nav nav-list">
	<!-- <li><a href="#!payments-demo" onclick="core.go(this.href);">Financials</a></li> -->
	<li><a id="users-edit-me" href="#!users-edit--entity_id-<?=$core->session['user_id']?>-me-1" onclick="core.go(this.href);">Update Profile</a></li>
	<li><a id="organizations-edit-me" href="#!organizations-edit--org_id-<?=$core->session['org_id']?>-me-1" onclick="core.go(this.href);">My Organization</a></li>
	<?if($core->session['is_active'] == 1 && $core->session['org_is_active'] == 1){?>
	<li><a id="orders-purchase_history" href="#!orders-purchase_history" onclick="core.go(this.href);">Purchase History</a></li>
		<!--
		<? if(!lo3::is_seller()){?>
		<li><a href="#!products-request" onclick="core.go(this.href);">Suggest A New Product</a></li>
		<?}?>
		-->
	<?}?>
	<?if(lo3::is_customer() && !lo3::is_seller()){?>
	<li><a id="reports-edit" href="#!reports-edit" onclick="core.go(this.href);">Reports</a></li>
	<?}?>
	<li><a id="users-change_password" href="#!users-change_password" onclick="core.go(this.href);">Change Your Password</a></li>
</ul>
<? core::replace('left'); ?>
