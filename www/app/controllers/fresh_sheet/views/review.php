<?
core::ensure_navstate(array('left'=>'left_dashboard'),'fresh_sheet-review','marketing');
core_ui::fullWidth();
core::head('Fresh Sheet','This page is used to review your fresh sheet');
lo3::require_permission();
lo3::require_login();

$this->test_send1()->js();
$this->test_send2()->js();

$domain_id = 0;
if(lo3::is_admin() || (lo3::is_market() && count($core->session['domains_by_orgtype_id'][2]) > 1))
{
	$domains = core::model('domains')->collection()->sort('name');
	if(lo3::is_market())
		$domains->filter('domain_id','in',$core->session['domains_by_orgtype_id'][2]);
	?>
	<form name="domainSelector" class="pull-right" style="position: relative; top: 8px;">
		<span style="position: relative; top: -3px;">Choose Market:</span> <select style="width: auto;" onchange="location.href='#!fresh_sheet-review--domain_id-'+this.options[this.selectedIndex].value;">
			<option value="0">Select a hub</option>
			<?foreach($domains as $domain){?>
			<option value="<?=$domain['domain_id']?>"<?=(($core->data['domain_id']==$domain['domain_id'])?' selected="selected"':'')?>><?=$domain['name']?></option>
			<?}?>
		</select>
	</form>
		
	<?
	if (isset($core->data['domain_id'])) {
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


for($i=1;$i<35;$i++)
{
	#echo('mkdir /var/www/new-production/www/img/'.$i.'/;<br />chmod 777 /var/www/new-production/www/img/'.$i.'/;<br />cp /var/www/production/www/img/'.$i.'/* /var/www/new-production/www/img/'.$i.'/;<br />');
}

page_header($core->i18n['nav2:marketadmin:freshsheet'],null,null, null,null, 'list');
echo($core->i18n['fresh_sheet:head']);

if($domain_id > 0)
{
	$fs_html = $this->generate_html($domain_id,true);
	?>
	<?if($fs_html == ''){?>
		<? if(lo3::is_admin()) { ?>
			<p>There are no products available for this hub this week.</p>
		<? } else { ?>
			<p>There are no products available for your fresh sheet this week.</p>
		<? } ?>

	<? } else { ?>

	<p>
		<input type="button" onclick="$('#bs1,#bs2').hide();$('#tf1').show()" class="btn" value="Send Test" />
		<input type="button" onclick="core.doRequest('/fresh_sheet/send',{'domain_id':<?=$domain_id?>});" class="btn btn-primary" value="Send Now" />
	</p>
	
	<form name="tf1" id="tf1" style="display: none;text-align:right;" onsubmit="return core.submit('/fresh_sheet/send',this,{'test_only':1,'email':$('#te1').val(),'domain_id':<?=$domain_id?>});">
		Send test to <input type="text" name="te1" id="te1" value="" />
		<input type="button" onclick="$('#bs1,#bs2').show();$('#tf1').hide()" class="button_primary" value="cancel" />
		<input type="submit" class="button_primary" value="send test" />
	</form>
	
	<?=$fs_html?>
	
	<hr>
	
	<p>
		<input type="button" onclick="$('#bs1,#bs2').hide();$('#tf2').show();" class="btn" value="Send Test" />
		<input type="button" onclick="core.doRequest('/fresh_sheet/send',{'domain_id':<?=$domain_id?>});" class="btn btn-primary" value="Send Now" />
	</p>
	
	<form name="tf2" id="tf2" style="display: none;text-align:right;" onsubmit="return core.submit('/fresh_sheet/send',this,{'test_only':1,'email':$('#te2').val(),'domain_id':<?=$domain_id?>});">
		<input type="text" name="te2" id="te2" value="" />
		<input type="button" onclick="$('#bs1,#bs2').show();$('#tf2').hide()" class="button_primary" value="cancel" />
		<input type="submit" class="button_primary" value="send test" />
	</form>
	<?
	}
}
?>