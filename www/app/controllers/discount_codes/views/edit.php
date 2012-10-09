<?php

core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Edit Discount Code','This page is to edit Discount Code Information');
lo3::require_permission();
lo3::require_login();
lo3::require_orgtype('market');

$hubs = core::model('domains')->collection()->sort('name');
$seller_restrict = core::model('organizations')->collection()->filter('allow_sell',1)->sort('full_org_name');
$buyer_restrict  = core::model('organizations')->collection()->sort('full_org_name');
$prod_sql = '
	select prod_id,concat_ws(\': \',domains.name,organizations.name,products.name) as prod_name
	from products 
	inner join organizations on (products.org_id=organizations.org_id)
	inner join organizations_to_domains on (organizations_to_domains.org_id=organizations.org_id and organizations_to_domains.is_home=1)
	inner join domains on (organizations_to_domains.domain_id=domains.domain_id)
	where products.is_deleted=0
	and   organizations.is_deleted=0
';
if(lo3::is_market())
{
	$hubs->filter('domain_id','in',$core->session['domains_by_orgtype_id'][2]);
	$prod_sql .= '
		and domains.domain_id in ('.implode(',',$core->session['domains_by_orgtype_id'][2]).')
	';
}
$prod_sql .= 'order by domains.name,organizations.name,products.name';
$products = new core_collection($prod_sql);

if(lo3::is_market())
{
	$buyer_restrict->filter('domains.domain_id','in',$core->session['domains_by_orgtype_id'][2]);
	$seller_restrict->filter('domains.domain_id','in',$core->session['domains_by_orgtype_id'][2]);
}

if(!is_numeric($core->data['disc_id']))
{
	$data = array();
}
else
{
	$data = core::model('discount_codes')->load();
}

core_ui::tabset('discounttabs');
$this->rules()->js();

page_header('Editing '.$data['name'],'#!discount_codes-list','cancel');
?>
<form name="discForm" method="post" action="/discount_codes/update" onsubmit="return core.submit('/discount_codes/update',this);" enctype="multipart/form-data">

	<div class="tabset" id="discounttabs">
		<div class="tabswitch" id="discounttabs-s1">
			Discounts
		</div>
	</div>
	
	<div class="tabarea" id="discounttabs-a1">
		<table class="form">
			<tr>
				<td class="label">Name</td>
				<td class="value"><input type="text" name="name" value="<?=$data['name']?>" /></td>
			</tr>
			<tr>
				<td class="label">Code</td>
				<td class="value"><input type="text" name="code" value="<?=$data['code']?>" /></td>
			</tr>
		<?if(lo3::is_admin() || count($core->session['domains_by_orgtype_id'][2])>1) 
		{?>
			<tr>
				<td class="label">Hub</td>
				<td class="value">
					<select name="domain_id">
						<?if(lo3::is_admin()){?><option value="0">Everyone</option><?}?>
						<?=core_ui::options($hubs,$data['domain_id'],'domain_id','name')?>
					</select>
				</td>
			</tr>
		<?}?>
			<tr>
				<td class="label">Start Date</td>
				<td class="value">
					<?=core_ui::date_picker('start_date',$data['start_date'])?>
				</td>
			</tr>
			<tr>
				<td class="label">End Date</td>
				<td class="value"><?=core_ui::date_picker('end_date',$data['end_date'])?></td>
			</tr>
			<tr>
				<td class="label">Type</td>
				<td class="value">
					<select name="discount_type">
						<?=core_ui::options(array('Fixed'=>'Dollar Amount','Percent'=>'Percentage'),$data['discount_type'],'value','text')?>
					</select>
				</td>
			</tr>
			<tr>
				<td class="label">Discount</td>
				<td class="value"><input type="text" name="discount_amount" value="<?=lo3_display_negative($data['discount_amount'])?>" /></td>
			</tr>
			<tr>
				<td class="label">Restrict to Product</td>
				<td class="value">
					<select name="restrict_to_product_id" style="width:550px;">
						<option value="0">All Products</option>
						<?=core_ui::options($products,$data['restrict_to_product_id'],'prod_id','prod_name')?>
					</select>
				</td>
			</tr>	
			<tr>
				<td class="label">Restrict to Buyer Org</td>
				<td class="value">
					<select name="restrict_to_buyer_org_id" style="width:550px;">
						<option value="0">Everyone</option>
						<?=core_ui::options($buyer_restrict,$data['restrict_to_buyer_org_id'],'org_id','full_org_name')?>
					</select>
				</td>
			</tr>
			<tr>
				<td class="label">Restrict to Seller Org</td>
				<td class="value">
					<select name="restrict_to_seller_org_id" style="width:550px;">
						<option value="0">Everyone</option>
						<?=core_ui::options($seller_restrict,$data['restrict_to_seller_org_id'],'org_id','full_org_name')?>
					</select>
				</td>
			</tr>
			
			<!-- NOTE: This is not yet enabled given complexities in LO3
			<tr> 
				<td class="label">Restrict to user type</td>
				<td class="value"><input type="text" name="restrict_to_account_type_id" value="<?=$data['restrict_to_account_type_id']?>" /></td>
			</tr> 
			-->
	
			<tr>
				<td class="label">Minimum order (0 for no min)</td>
				<td class="value"><input type="text" name="min_order" value="<?=lo3_display_negative($data['min_order'])?>" /></td>
			</tr>
			<tr>
				<td class="label">Maximum order (0 for no max)</td>
				<td class="value"><input type="text" name="max_order" value="<?=lo3_display_negative($data['max_order'])?>" /></td>
			</tr>
			<tr>
				<td class="label">Max global uses (0 for no limit)</td>
				<td class="value"><input type="text" name="nbr_uses_global" value="<?=$data['nbr_uses_global']?>" /></td>
			</tr>
			<tr>
				<td class="label">Max per user uses (0 for no limit)</td>
				<td class="value"><input type="text" name="nbr_uses_user" value="<?=$data['nbr_uses_user']?>" /></td>
			</tr>
		</table>
	</div>
	<input type="hidden" name="disc_id" value="<?=$data['disc_id']?>" />
	<? save_buttons(); ?>
</form>