<? if(lo3::is_admin()){?>
<div class="header_1"><?=$core->i18n['nav2:marketadmin']?></div>
<ul class="subheader">
	<li class="subheader_1"><a href="#!market-list" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:hubs']?></a></li>
	<li class="subheader_1"><a href="#!users-list" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:users']?></a></li>
	<li class="subheader_1"><a href="#!organizations-list" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:organizations']?></a></li>
	<li class="subheader_1"><a href="#!orders-list" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:orders']?></a></li>
	<li class="subheader_1"><a href="#!sold_items-list" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:sold_items']?></a></li>
	<li class="subheader_1"><a href="#!products-list" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:products']?></a></li>
	<li class="subheader_1"><a href="#!events-list" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:usereventlog']?></a></li>
	<li class="subheader_1"><a href="#!delivery_tools-view" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:weeklysalesndeliveryinfo']?></a></li>
	<li class="subheader_1"><a href="#!sent_emails-list" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:sentemails']?></a></li>
	<li class="subheader_1"><a href="#!emails-tests" onclick="core.go(this.href);"><?=$core->i18n['nav2:emails:tests']?></a></li>
	<li class="subheader_1"><a href="#!taxonomy-list" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:producttaxonomy']?></a></li>
	<!--<li><a href="#!translations-list" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:translations']?></a></li>-->
	<li class="subheader_1"><a href="#!dictionaries-edit" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:dictionary']?></a></li>
	<!--<li class="subheader_1"><a href="#!customizations-list" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:customizations']?></a></li>-->
	<!--<li class="subheader_1"><a href="#!payments-list" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:payments']?></a></li>-->
	<li class="subheader_1"><a href="#!units-list" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:units']?></a></li>
	<li class="subheader_1"><a href="#!reports-edit" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:reports']?></a></li>
	<li class="subheader_1"><a href="#!referrals-list" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:referrals']?></a></li>
	<li class="subheader_1"><a href="#!metrics-overview" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:metrics']?></a></li>
	<!--<li class="subheader_1"><a href="#!admin_roles-list" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:adminroles']?></a></li>-->
</ul>
<br />
<div class="header_1">Marketing</div>
<ul class="subheader">
	<li class="subheader_1"><a href="#!discount_codes-list" onclick="core.go(this.href);">Discount Codes</a></li>
	<li class="subheader_1"><a href="#!newsletters-list" onclick="core.go(this.href);">Newsletters</a></li>
	<li class="subheader_1"><a href="#!market_news-list" onclick="core.go(this.href);">Market News</a></li>
	<!--<li class="subheader_1"><a href="#!photos-list" onclick="core.go(this.href);">Photos</a></li>-->
	<li class="subheader_1"><a href="#!weekly_specials-list" onclick="core.go(this.href);">Featured Deals</a></li>
	<li class="subheader_1"><a href="#!fresh_sheet-review" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:freshsheet']?></a></li>
</ul>
<br />
<?}?>
<? if(lo3::is_market()){?>
<div class="header_1"><?=$core->i18n['nav2:marketadmin']?></div>
<ul class="subheader">
	<?if(count($core->session['domains_by_orgtype_id'][2]) > 1){?>
	<li class="subheader_1"><a href="#!market-list" onclick="core.go(this.href);">Hubs</a></li>
	<?}else{?>
	<li class="subheader_1"><a href="#!market-edit--domain_id-<?=$core->session['domains_by_orgtype_id'][2][0]?>" onclick="core.go(this.href);">Hub</a></li>
	<?}?>
	<li class="subheader_1"><a href="#!users-list" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:users']?></a></li>
	<li class="subheader_1"><a href="#!organizations-list" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:organizations']?></a></li>
	<li class="subheader_1"><a href="#!orders-list" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:orders']?></a></li>
	<li class="subheader_1"><a href="#!sold_items-list" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:sold_items']?></a></li>
	<li class="subheader_1"><a href="#!products-list" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:products']?></a></li>
	<li class="subheader_1"><a href="#!delivery_tools-view" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:weeklysalesndeliveryinfo']?></a></li>
	<li class="subheader_1"><a href="#!reports-edit" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:reports']?></a></li>
	
</ul>
<br />
<div class="header_1">Marketing</div>
<ul class="subheader">
	<li class="subheader_1"><a href="#!discount_codes-list" onclick="core.go(this.href);">Discount Codes</a></li>
	<li class="subheader_1"><a href="#!newsletters-list" onclick="core.go(this.href);">Newsletters</a></li>
	<li class="subheader_1"><a href="#!market_news-list" onclick="core.go(this.href);">Market News</a></li>
	<!--<li class="subheader_1"><a href="#!photos-list" onclick="core.go(this.href);">Photos</a></li> -->
	<li class="subheader_1"><a href="#!weekly_specials-list" onclick="core.go(this.href);">Featured Deals</a></li>
	<li class="subheader_1"><a href="#!fresh_sheet-review" onclick="core.go(this.href);"><?=$core->i18n['nav2:marketadmin:freshsheet']?></a></li>
</ul>
<br />
<?}?>
<? if(lo3::is_customer() && lo3::is_seller()){?>
<div class="header_1">Sales Information</div>
<ul class="subheader">
	<li class="subheader_1"><a href="#!products-list" onclick="core.go(this.href);">Products</a></li>
	<li class="subheader_1"><a href="#!orders-current_sales" onclick="core.go(this.href);">Current Sales</a></li>
	<li class="subheader_1"><a href="#!delivery_tools-view" onclick="core.go(this.href);">Upcoming Deliveries</a></li>
	<li class="subheader_1"><a href="#!reports-edit" onclick="core.go(this.href);">Reports</a></li>
	<!-- <li class="subheader_1"><a href="#!orders-sales_report" onclick="core.go(this.href);">Sales History</a></li> -->
	<!-- <li class="subheader_1"><a href="#!payment_report-view" onclick="core.go(this.href);">Payment History</a></li> -->
</ul>
<br />
<?}?>
<div class="header_1">Account Information</div>
<ul class="subheader">
	<li class="subheader_1"><a href="#!users-edit--entity_id-<?=$core->session['user_id']?>-me-1" onclick="core.go(this.href);">Update Profile</a></li>
	<li class="subheader_1"><a href="#!organizations-edit--org_id-<?=$core->session['org_id']?>-me-1" onclick="core.go(this.href);">My Organization</a></li>
	<?if($core->session['is_active'] == 1 && $core->session['org_is_active'] == 1){?>
	<?if(lo3::is_customer() && !lo3::is_seller()){?>
	<li class="subheader_1"><a href="#!reports-edit" onclick="core.go(this.href);">Reports</a></li>
	<?}?>
	<li class="subheader_1"><a href="#!orders-purchase_history" onclick="core.go(this.href);">Purchase History</a></li>
		<? if(!lo3::is_seller()){?>
		<li class="subheader_1"><a href="#!products-request" onclick="core.go(this.href);">Suggest A New Product</a></li>
		<?}?>
	<?}?>
	<li class="subheader_1"><a href="#!payments-demo" onclick="core.go(this.href);">Financial Management</a></li>
</ul>
<? core::replace('left'); ?>