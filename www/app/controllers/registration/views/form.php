<?
global $core;
core::ensure_navstate(array('left'=>'left_blank'));
core::head($core->i18n['title:reg'],$core->i18n['description:reg']);
lo3::require_permission();
core_ui::fullWidth();

# get teh list of possible domains
#
$domains = core::model('domains')->collection(array('domain_id','name','detailed_name','allowed_groups'))->sort('detailed_name');
#->filter('is_live',1)
if($core->data['show_secret'] != 1)
	$domains->filter('show_on_homepage',1);
$domain_id = intval($core->data['domain_id']);

if($domain_id == 0 && $core->config['domain']['domain_id'] > 1)
{
	$domain_id = $core->config['domain']['domain_id'];
}

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

<form name="regform" class="form-horizontal" action="registration/process" onsubmit="return core.submit('/registration/process',this);">
		<div class="row">
			<div class="span12">
				<h2><?=$core->i18n['header:reg:choosetype']?></h2>
			</div>
		</div>
		<div class="row">
			<div class="span3" style="font-size: 120%;">
				<?=core_ui::checkdiv('allow_buyer',$core->i18n['field:reg:check-buyfood'],false)?>
			</div>
			<div class="span9" style="font-size: 120%;">
				<?=core_ui::checkdiv('allow_sell',$core->i18n['field:reg:check-sellfood'],false)?>
			</div>
			<!--<div id="checkdiv_buy_biz" class="checkdiv checkdiv_checked">I would like to buy food</div>-->
		</div>
		<div class="row" id="reg_mainform"<?=(($domain_id>0)?'':' style="display:none;"')?>>
			<div class="span12">
				<br />
				<h2><?=$core->i18n['header:reg:mainform']?></h2>
			
			<?=core_form::input_text($core->i18n['field:company:name'],'company_name','')?>
			<?=core_form::input_text($core->i18n['field:customer:firstname'],'first_name','',array('required' => true))?>
			<?=core_form::input_text($core->i18n['field:customer:lastname'],'last_name','',array('required' => true))?>
			<?=core_form::input_text($core->i18n['field:customer:email'],'email','',array('required' => true))?>
			<?=core_form::input_text($core->i18n['field:customer:email-match'],'email_confirm','',array('required' => true))?>
			
			<?=core_form::input_password($core->i18n['field:customer:password'],'password','',array('required' => true))?>
			<?=core_form::input_password($core->i18n['field:customer:password-match'],'password_confirm','',array('required' => true))?>
			
			
			
			
			
			<script>
				$("input[name=address]").change(function(event){
					setLatLon();
				});
				$("input[name=city]").change(function(event){
					setLatLon();
				});
				$("input[name=postal_code]").change(function(event){
					setLatLon();
				});
				$("select[name=region_id]").change(function(event){
					setLatLon();
				});
				function setLatLon() {
					core.address.lookupLatLong($("input[name=address]").val(), $("input[name=city]").val(), $("select[name=region_id]").find('option:selected').text(), $("input[name=postal_code]").val());
				}	
			</script>		
		
			<h2><?=$core->i18n['header:reg:bizinfo']?></h2>
			
			<?=core_form::input_text($core->i18n['field:address:street'],'address','',array('required' => true))?>
			<?=core_form::input_text($core->i18n['field:address:city'],'city','',array('required' => true))?>
			
			<div class="control-group">
				<label class="control-label" for="label"><?=core_form::required()?><?=$core->i18n['field:address:state']?></label>
					<div class="controls">
						<select name="region_id">
							<option value="0"></option>
							<?=core_ui::options($regions,null,'region_id','default_name')?>					
						</select>
					</div>
			</div>
	
			<?=core_form::input_text($core->i18n['field:address:postalcode'],'postal_code','',array('required' => true))?>
			<?=core_form::input_text($core->i18n['field:address:telephone'],'telephone','',array('required'=>true))?>
			
			
			<div style="display: none;" id="bad_address" class="info_area info_area_speech">We cannot locate your address. The address must be valid before you may save it.</div>
			<input type="hidden" id="latitude" name="latitude" value="" />
			<input type="hidden" id="longitude" name="longitude" value="" />

			
			
			<h2><?=$core->i18n['header:reg:spamprotection']?></h2>
			<div class="control-group">
				<label class="control-label" for="label"><?=core::i18n('field:reg:spam-protect',$core->session['spammer_nums'][0],$core->session['spammer_nums'][1],$core->session['spammer_nums'][2])?></label>
				<div class="controls">
					<?foreach($fields as $field){?>
						<?=$field?>
					<?}?>
				</div>
			</div>
			
			
			<h2><?=$core->i18n['header:reg:newsletter-signup']?></h2>
			<?=core_ui::checkdiv('subscribe_mailchimp',$core->i18n['field:reg:check-newsletter'])?>
			<br />&nbsp;<br />
			<h2><?=$core->i18n['header:reg:tos']?><?=core_form::required()?></h2>
			<?=core_ui::checkdiv('tos_approve',$core->i18n['field:reg:check-tos'], false, "core.registration.tosModalPopup()")?>
			
			<?if($core->config['stage'] == 'testing' || $core->config['stage'] == 'qa' || $core->config['stage'] == 'dev'){?>
				<br />
				<input type="button" value="Testing/QA ONLY" class="button_secondary" onclick="core.registration.fakeFill((<?=$core->session['spammer_nums'][0]?>+<?=$core->session['spammer_nums'][1]?>),'<?=$core->session['spammer_field']?>');" />
			<?}?>
		</div>
	</div>
	
	
 	<div class="row">
		<div class="span12">
			<input type="submit" value="<?=$core->i18n['button:signup']?>" class="btn btn-primary btn-large pull-right" />
		</div>
	</div>
	<input type="hidden" name="postauth_url" value="<?=$core->config['postauth_url']?>" />
		
	
	<!-- TOS modal -->
	<div id="tosModal" class="modal hide fade">
	    <div class="modal-body">
			<? core::process_command('misc/tos');?>
	    </div>
	    <div class="modal-footer">
			<button onclick="$('input[name=tos_approve]').removeAttr('checked')" class="btn" data-dismiss="modal" aria-hidden="true">Cancel</button>
			<button onclick="$('input[name=tos_approve]').attr('checked', 'checked')" class="btn btn-primary" data-dismiss="modal" aria-hidden="true">I have read the Terms of Service</button>
	    </div>
	</div>
</form>
