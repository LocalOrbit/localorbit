<?php
core::ensure_navstate(array('left'=>'left_dashboard'),'market-list','market-admin');
core_ui::fullWidth();
core::head('Edit Market','This page is used to edit markets');
lo3::require_permission();
lo3::require_login();


# javascript to load tabset, market-specific functionality
core_ui::tabset('markettabs');
core_ui::load_library('js','market.js');
core_ui::load_library('js','address.js');
$this->rules()->js();

# load misc data
global $data, $org;
$data = core::model('domains')->autojoin(
			'left',
			'domains_branding branding',
			'(domains.domain_id=branding.domain_id and branding.is_temp = 0)',
			array('branding_id','header_font', 'background_color', 'background_id', 'text_color', 'is_temp')
		)->load();

# if the hub you were trying to edit is NOT the same as YOUR hub, then
# make sure the user is actually an admin. Otherwise, they can be a market manager
if(lo3::is_admin() || count($core->session['domains_by_orgtype_id'][2]) > 1)
{
	page_header('Editing Market: '.$data['name'],'#!market-list','Cancel', 'link', null, 'cog');
}
else
{
	lo3::require_orgtype('market');
	page_header('Editing Market: '.$data['name'], null, null, null, null, 'cog');
}

$managed = new core_collection('
	select organizations.org_id,name
	from organizations
	inner join organizations_to_domains on (
		organizations_to_domains.domain_id='.$data['domain_id'].'
		and organizations_to_domains.org_id=organizations.org_id
		and organizations_to_domains.orgtype_id=2
	)

');

$org  = core::model('organizations')->collection()->filter('organizations_to_domains.orgtype_id',2)->filter('organizations_to_domains.domain_id',$data['domain_id']);
$zones = core::model('timezones')->collection()->sort('offset_seconds','desc');
$org->next();

# get the list of domains onwhich cross selling *could* occur
$domains = core::model('domains')->collection();
$cross_sells = core::model('domain_cross_sells')->collection()->filter('domain_id',$data['domain_id']);
$allows = array();
foreach($cross_sells as $cross_sell)
	$allows[$cross_sell['accept_from_domain_id']] = true;

$tabs = array('Market Settings','Addresses','Delivery','Branding','Style Chooser','Market Info','Payments/Fees');
if(lo3::is_admin())
{
	$tabs[] = 'Cross Selling';
	$tabs[] = 'Features';
}
?>
<form name="marketForm" class="form-horizontal" method="post" action="/market/save" target="uploadArea" onsubmit="return core.submit('/market/save',this);" enctype="multipart/form-data">
	<?=core_ui::tab_switchers('markettabs',$tabs)?>

	<div class="tab-content">
		<div class="tab-pane tabarea active" id="markettabs-a1">

			<fieldset>
				<?if(lo3::is_admin()){?>
				<div class="control-group">
					<label class="control-label">
						Domain ID
						<?=core_ui::help_tip("Domain ID", "A unique number associated with the market. It is most notably used for passing data for creating custom email templates.")?>
					</label>
					<div class="controls">
						<?=$data['domain_id']?>
					</div>
				</div>
				<?}?>
				<div class="control-group">
					<label class="control-label">
						Name
						<?=core_ui::tool_tip("Name", "Don't forget to double check your spelling")?>
					</label>
					<div class="controls">
						<input type="text" name="name" value="<?=$data['name']?>" />
					</div>
				</div>
				<?if(lo3::is_admin()){?>
				<div class="control-group">
					<label class="control-label">Managed By</label>
					<div class="controls">
						<? foreach($managed as $managed_org){?>
						<a href="#!organizations-edit--org_id-<?=$managed_org['org_id']?>"><?=$managed_org['name']?></a><br>
						<?}?>
					</div>
				</div>
				<div class="control-group">
					<label class="control-label">Hostname</label>
					<div class="controls">
						<input type="text" name="hostname" value="<?=$data['hostname']?>" />
						<?/*
						<div class="input-append">
							<input type="text" name="hostname" value="<?=$data['hostname']?>" />
							<span class="add-on">.localorb.it</span>
						</div>
						*/?>
					</div>
				</div>
				<?}?>
				<div class="control-group">
					<label class="control-label">Timezone</label>
					<div class="controls">
						<select name="tz_id">
							<?=core_ui::options($zones,$data['tz_id'],'tz_id','tz_name')?>
						</select>
					</div>
				</div>

				
					
				<div class="control-group">
					<label class="control-label">
						Apply Daylight Savings
						<?=core_ui::help_tip("Apply Daylight Savings", "This box needs to be checked for all states that recognize daylight savings time.  Arizona and Hawaii are the only two states in the US that do not.")?>
					</label>
					<div class="controls">
						<?=core_ui::checkdiv('do_daylight_savings','', ($data['do_daylight_savings'] == 1))?>
					</div>
				</div>
				
				
				<?
					if(lo3::is_admin()){
						echo core_form::input_check('Is Live','is_live',$data['is_live']);
					}
				?>
				
				<?= core_form::input_check('Close Store','is_closed',$data['is_closed'], array('sublabel'=>'A closed message will appear on the Shop page.')); ?>
				<?
					if(lo3::is_admin()){
						echo core_form::input_check('Login Enabled','login_enabled',$data['login_enabled'],, array('sublabel'=>'Unchecking this and saving will prevent all users from logging into this market.'));
					}
				?>
				
				<?if(lo3::is_admin()){?>
					<div class="control-group">
						<label class="control-label">
							Auto-activate Organizations
							<?=core_ui::help_tip("Auto-activate Organizations", "A buyer can register and shop without Market Manager approval.")?>
						</label>
						<div class="controls">
							<?=core_ui::checkdiv('autoactivate_organization','', ($data['autoactivate_organization'] == 1))?>
						</div>
					</div>
				<?}?>

			</fieldset>
		</div>
		<div class="tab-pane tabarea" id="markettabs-a2">
			<? $this->addresses(); ?>
		</div>

		<div class="tab-pane tabarea" id="markettabs-a3">
			<? $this->delivery();	?>
		</div>
		<div class="tab-pane tabarea" id="markettabs-a4">
			<? $this->branding(); ?>
		</div>
		<div class="tab-pane tabarea" id="markettabs-a5">
			<? $this->style_chooser(); ?>
		</div>
		<div class="tab-pane tabarea" id="markettabs-a6">
			<? $this->market_info(); ?>
		</div>
		<div class="tab-pane tabarea" id="markettabs-a7">
			<? $this->payments_fees();?>
		</div>
		<? if(lo3::is_admin()){?>
		<div class="tab-pane tabarea" id="markettabs-a8">

			<?php foreach($domains as $domain){ ?>
				<?=core_form::input_check('<small>Accept products from</small><br><strong style="position: relative; top: -3px;">'.$domain['name'].'</strong>','accept_products_from_'.$domain['domain_id'],$allows[$domain['domain_id']])?>
			<?}?>

		</div>

		<div class="tab-pane tabarea" id="markettabs-a9">
			<fieldset>

				<?=core_form::input_check('Require sellers to accept all delivery options','feature_require_seller_all_delivery_opts',$data,false,$core->i18n['hub:features:req_selr_all_delv_opts'])?>
				<?=core_form::input_check('Force items at checkout to soonest delivery option','feature_force_items_to_soonest_delivery',$data,false,$core->i18n['hub:features:items_to_1st_delv'])?>
				<?=core_form::input_check('Sellers enter prices before fees','feature_sellers_enter_price_without_fees',$data,false,$core->i18n['hub:features:sellers_enter_price_without_fees'])?>
				<?=core_form::input_check('Sellers cannot modify cross-sells','feature_sellers_cannot_manage_cross_sells',$data,false,$core->i18n['hub:features:sellers_cannot_modify_cross_sells'])?>
				<?=core_form::input_check('Sellers can change delivery statuses','feature_sellers_mark_items_delivered',$data,false,$core->i18n['hub:features:feature_sellers_mark_items_delivered'])?>
				<?=core_form::input_check('Allow anonymous shopping','feature_allow_anonymous_shopping',$data,false,'Note: checking this feature will also enable organization auto-activation, credit card payments, and disable POs',null,false,"market.toggleAnon();")?>

				<div class="control-group" id="default_homepage_selector"<?=(($data['feature_allow_anonymous_shopping'] != '1')?' style="display: none;"':'')?>>
					<label class="control-label">Homepage</label>
					<div class="controls">
						<select name="default_homepage">
							<?=core_ui::options(array('Login'=>'Login','Market Info'=>'Market Info','Our Sellers'=>'Our Sellers','Shop'=>'Shop'),$data['default_homepage'])?>
						</select>
					</div>
				</div>
			</fieldset>
		</div>
		<?}?>

	</div>

	<?
	if(lo3::is_admin())
		save_buttons(true);
	if(lo3::is_market())
		save_only_button();
	?>
	<input type="hidden" name="hostname" value="<?=$data['hostname']?>" />
	<input type="hidden" name="domain_id" value="<?=$data['domain_id']?>" />
	<input type="hidden" name="org_id" value="<?=$org['org_id']?>" />

</form>