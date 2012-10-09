<?
core::ensure_navstate(array('left'=>'left_blank'));
core::head($core->i18n['title:reg'],$core->i18n['description:reg']);
lo3::require_permission();

# get teh list of possible domains
#
$domains = core::model('domains')->collection(array('domain_id','name','detailed_name','allowed_groups'))->sort('detailed_name');
#->filter('is_live',1)
if($core->data['show_secret'] != 1)
	$domains->filter('show_on_homepage',1);
$domain_id = intval($core->data['domain_id']);

# generate fake spammer fields
$fields = $this->generate_fake_fields();

# move the domain list to javascript as well, and load the js library for this page
core::js('core.domainList = '.$domains->to_json().';');
core_ui::load_library('js','registration.js');
core_ui::load_library('js','address.js');
$this->rules()->js();
core_ui::tabset('regtabs');

$regions = core::model('directory_country_region')
	->collection()
	->filter('country_id','in',array('US','CA'))
	->sort('(country_id <> \'US\')');

# check to see if we're supposed to redirect after registration
if($core->data['redirect_to_checkout'] == 1)
{
	$core->config['postauth_url'] = '#!catalog-checkout';
}
?>
<form name="regform" action="registration/process" onsubmit="return core.submit('/registration/process',this);">
	<div class="tabset" id="regtabs">
		<div class="tabswitch" id="regtabs-s1">
			Registration
		</div>
	</div>
	
	<div class="tabarea" id="regtabs-a1">
		<? if($domain_id>0){?>
		<input type="hidden" name="domain_id" value="<?=$domain_id?>" />		
		<?}else{?>
		<div id="reg_pickloc">
			<h2><?=$core->i18n['header:reg:chooseloc']?></h2>
			<select name="domain_id" style="width: 340px;" class="" onchange="core.registration.toggleForm();">
				<option value=""><?=$core->i18n['field:reg:localto']?></option>
				<?=core_ui::options($domains,$core->config['domain']['domain_id'],'domain_id','detailed_name')?>
				<option value="-1">I don't see my location listed above</option>
			</select>
			<div id="email_signupform" style="display: none;margin-top: 10px;">
				Don't see your location on the menu? Please sign up for our email list and we'll let you know when a Local Orbit site launches in your community.
				<br />&nbsp;<br />
				<a class="arrow_link" target="_blank" href="http://localorb.us1.list-manage.com/subscribe?u=097ff089a21bda22fa71668f5&id=d0cc696de4">Sign up for our email list</a>
			</div>
		</div>
		<?}?>
		
		<div id="reg_pickgroup"<?=(($domain_id>0)?'':' style="display:none;"')?>>
			<h2><?=$core->i18n['header:reg:choosetype']?></h2>
			<?=core_ui::checkdiv('allow_buyer',$core->i18n['field:reg:check-buyfood'],false)?>
			<?=core_ui::checkdiv('allow_sell',$core->i18n['field:reg:check-sellfood'],false)?>
			<!--<div id="checkdiv_buy_biz" class="checkdiv checkdiv_checked">I would like to buy food</div>-->
		</div>
		<div id="reg_mainform"<?=(($domain_id>0)?'':' style="display:none;"')?>>
			<h2><?=$core->i18n['header:reg:mainform']?></h2>
			<table class="form">
				<tr>				
					<td class="label"><?=$core->i18n['field:company:name']?></td>
					<td class="value">
						<input type="text" name="company_name" value="" />
						<!-- <?=info('this is a comment about company name')?> -->
					</td>
				</tr>
				<tr>
					<td class="label"><?=$core->i18n['field:customer:firstname']?><?=core_form::required()?></td>
					<td class="value">
						<input type="text" name="first_name" value="" />
						<!-- <?=info('this is a comment about first name','paperclip')?> -->
					</td>
				</tr>
				<tr>
					<td class="label"><?=$core->i18n['field:customer:lastname']?><?=core_form::required()?></td>
					<td class="value">
						<input type="text" name="last_name" value="" />
					<!--	<?=info('this is a comment about first name','edit')?> -->
					</td>
				</tr>
				<tr>
					<td class="label"><?=$core->i18n['field:customer:email']?><?=core_form::required()?></td>
					<td class="value"><input type="text" name="email" value="" /></td>
				</tr>
				<tr>
					<td class="label"><?=$core->i18n['field:customer:email-match']?></td>
					<td class="value"><input type="text" name="email_confirm" value="" /></td>
				</tr>
				<tr>
					<td class="label"><?=$core->i18n['field:customer:password']?></td>
					<td class="value"><input type="password" name="password" value="" /></td>
				</tr>
				<tr>
					<td class="label"><?=$core->i18n['field:customer:password-match']?></td>
					<td class="value"><input type="password" name="password_confirm" value="" /></td>
				</tr>
			</table>
			<h2><?=$core->i18n['header:reg:bizinfo']?></h2>
			<table class="form">
				<tr>
					<td class="label"><?=$core->i18n['field:address:street']?></td>
					<td class="value"><input type="text" name="address" value="" onblur="core.address.lookupLatLong(this.form.address.value,this.form.city.value,this.form.region_id.options[this.form.region_id.selectedIndex].text,this.form.postal_code.value);" /></td>
				</tr>
				<tr>
					<td class="label"><?=$core->i18n['field:address:city']?></td>
					<td class="value"><input type="text" name="city" value="" onblur="core.address.lookupLatLong(this.form.address.value,this.form.city.value,this.form.region_id.options[this.form.region_id.selectedIndex].text,this.form.postal_code.value);" /></td>
				</tr>
				<tr>
					<td class="label"><?=$core->i18n['field:address:state']?></td>
					<td class="value">
						<select name="region_id" onchange="core.address.lookupLatLong(this.form.address.value,this.form.city.value,this.form.region_id.options[this.form.region_id.selectedIndex].text,this.form.postal_code.value);">
							<option value="0"></option>
							<?=core_ui::options($regions,null,'region_id','default_name')?>					
						</select>
					</td>
				</tr>
				<tr>
					<td class="label"><?=$core->i18n['field:address:postalcode']?></td>
					<td class="value"><input type="text" name="postal_code" onblur="core.address.lookupLatLong(this.form.address.value,this.form.city.value,this.form.region_id.options[this.form.region_id.selectedIndex].text,this.form.postal_code.value);" value="" /></td>
				</tr>
				<tr>
					<td class="label"><?=$core->i18n['field:address:telephone']?></td>
					<td class="value"><input type="text" name="telephone" value="" /></td>
				</tr>
				<tr>
					<td class="label"><?=$core->i18n['field:address:fax']?></td>
					<td class="value"><input type="text" name="fax" value="" /></td>
				</tr>
			</table>
			<div id="bad_address" class="info_area info_area_speech">We cannot locate your address. The address must be valid before you may save it.</div>
			<input type="hidden" id="latitude" name="latitude" value="" />
			<input type="hidden" id="longitude" name="longitude" value="" />

			<h2><?=$core->i18n['header:reg:spamprotection']?></h2>
			<table class="form">
				<tr>
					<td class="label"><?=core::i18n('field:reg:spam-protect',$core->session['spammer_nums'][0],$core->session['spammer_nums'][1],$core->session['spammer_nums'][2])?></td>
					<td class="value">
						<?foreach($fields as $field){?>
							<?=$field?>
						<?}?>
					</td>
				</tr>
			</table>
			
			
			<h2><?=$core->i18n['header:reg:newsletter-signup']?></h2>
			<?=core_ui::checkdiv('subscribe_mailchimp',$core->i18n['field:reg:check-newsletter'])?>
			
			<h2><?=$core->i18n['header:reg:tos']?><?=core_form::required()?></h2>
			<?=core_ui::checkdiv('tos_approve',$core->i18n['field:reg:check-tos'])?>


		</div>
		
		<?if($core->config['stage'] == 'testing' || $core->config['stage'] == 'qa'){?>
		<br />
		<input type="button" value="Testing/QA ONLY" class="button_secondary" onclick="core.registration.fakeFill((<?=$core->session['spammer_nums'][0]?>+<?=$core->session['spammer_nums'][1]?>),'<?=$core->session['spammer_field']?>');" />
		<?}?>
	</div>
	<div class="buttonset">
		<input type="submit" value="<?=$core->i18n['button:signup']?>" class="button_primary" />
	</div>
	<input type="hidden" name="postauth_url" value="<?=$core->config['postauth_url']?>" />
</form>
<br />