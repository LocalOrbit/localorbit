<?
core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Fresh Sheet','This page is used to review your fresh sheet');
lo3::require_permission();
lo3::require_login();
page_header($core->i18n['nav2:marketadmin:freshsheet']);
echo($core->i18n['fresh_sheet:head']);

$this->test_send1()->js();
$this->test_send2()->js();

$domain_id = 0;
if(lo3::is_admin() || (lo3::is_market() && count($core->session['domains_by_orgtype_id'][2]) > 1))
{
	$domains = core::model('domains')->collection()->sort('name');
	if(lo3::is_market())
		$domains->filter('domain_id','in',$core->session['domains_by_orgtype_id'][2]);
	?>
	<form name="domainSelector">
		<select style="width: auto;" onchange="location.href='#!fresh_sheet-review--domain_id-'+this.options[this.selectedIndex].value;">
			<option value="0">Select a hub</option>
		<?foreach($domains as $domain){?>
			<option value="<?=$domain['domain_id']?>"<?=(($core->data['domain_id']==$domain['domain_id'])?' selected="selected"':'')?>><?=$domain['name']?></option>
		<?}?>
		</select>
	</form>
	<br />
		
	<?
	if(isset($core->data['domain_id']))
	{
		$domain_id = $core->data['domain_id'];
	}
}
else if(lo3::is_market() && count($core->session['domains_by_orgtype_id'][2]) == 1)
{
	?>
	<input type="hidden" name="domain_id" value="<?=$core->session['domains_by_orgtype_id'][2][0]?>" />
	<?
	$domain_id = $core->session['domains_by_orgtype_id'][2][0];
}
else
{
	lo3::require_admin();
}

if($domain_id > 0)
{
	$fs_html = $this->generate_html($domain_id,true);
	?>
	<?if($fs_html == ''){?>
		<?if(lo3::is_admin()){?>
			There are no products available for this hub this week.
		<?}else{?>
			There are no products available for your fresh sheet this week. 
		<?}?>
	<?}else{?>
	<div class="buttonset" id="bs1">
		<input type="button" onclick="$('#bs1,#bs2').hide();$('#tf1').show()" class="button_primary" value="send test" />
		<input type="button" onclick="core.doRequest('/fresh_sheet/send',{'domain_id':<?=$domain_id?>});" class="button_primary" value="send now" />
	</div>
	<form name="tf1" id="tf1" style="display: none;text-align:right;" onsubmit="return core.submit('/fresh_sheet/send',this,{'test_only':1,'email':$('#te1').val(),'domain_id':<?=$domain_id?>});">
		Send test to <input type="text" name="te1" id="te1" value="" />
		<input type="button" onclick="$('#bs1,#bs2').show();$('#tf1').hide()" class="button_primary" value="cancel" />
		<input type="submit" class="button_primary" value="send test" />
	</form>
	<?=$fs_html?>
	<div class="buttonset" id="bs2">
		<input type="button" onclick="$('#bs1,#bs2').hide();$('#tf2').show();" class="button_primary" value="send test" />
		<input type="button" onclick="core.doRequest('/fresh_sheet/send',{'domain_id':<?=$domain_id?>});" class="button_primary" value="send now" />
	</div>
	<form name="tf2" id="tf2" style="display: none;text-align:right;" onsubmit="return core.submit('/fresh_sheet/send',this,{'test_only':1,'email':$('#te2').val(),'domain_id':<?=$domain_id?>});">
		<input type="text" name="te2" id="te2" value="" />
		<input type="button" onclick="$('#bs1,#bs2').show();$('#tf2').hide()" class="button_primary" value="cancel" />
		<input type="submit" class="button_primary" value="send test" />
	</form>
	<?
	}
}
?>