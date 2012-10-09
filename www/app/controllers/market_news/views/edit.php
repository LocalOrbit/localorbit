<?php

core::ensure_navstate(array('left'=>'left_dashboard'));
core::head('Buy and Sell Local Food on Local Orbit - Edit Market News','This page is used to edit Market News');
lo3::require_permission();
lo3::require_login();

core_ui::tabset('marketnewstabs');
core_ui::rte();
$this->rules()->js();

$hubs = core::model('domains')->collection();						
if (lo3::is_market()) { 
	$hubs = $hubs->filter('domain_id', 'in', implode(',', $core->session['domains_by_orgtype_id'][2]));							
} 
$hubs = $hubs->sort('name');

if($core->data['mnews_id'] == 0)
{
	$data = array(
		'domain_id'=>$core->config['domain']['domain_id'],
	);
}
else
{
	$data = core::model('market_news')->load();
}


# if the hub you were trying to edit is NOT the same as YOUR hub, then 
# make sure the user is actually an admin. Otherwise, they can be a market manager
if(!in_array($data['domain_id'],$core->session['domains_by_orgtype_id'][2]))
{
	lo3::require_orgtype('admin');
}
else
{
	lo3::require_orgtype('market');
}


page_header('Editing '.$data['title'],'#!market_news-list','cancel');
?>

<form name="marketnewsform" method="post" action="/market_news/update" onsubmit="return core.submit('/market_news/update',this);" enctype="multipart/form-data">
	<div class="tabset" id="marketnewstabs">
		<div class="tabswitch" id="marketnewstabs-s1">
			Market News
		</div>
	</div>
	<div class="tabarea" id="marketnewstabs-a1">
		<table class="form">
			<?if(count($core->session['domains_by_orgtype_id'][2]) > 1){?>
			<tr>
				<td class="label">Hub</td>
				<td class="value">
					<select name="domain_id">
						<option value="0">Select a hub</option>							
						<?=core_ui::options($hubs,$data['domain_id'],'domain_id','name')?>
					</select>
				</td>
			</tr>
			<?}?>
			<tr>
				<td class="label">Title</td>
				<td class="value"><input type="text" name="title" value="<?=$data['title']?>" /></td>
			</tr>
			<tr>
				<td class="label">Content</td>
				<td class="value"><textarea id="rte" class="rte" name="content" rows="7" cols="73"><?=$data['content']?></textarea></td>
			</tr>				
		</table>
	</div>
	<?if(count($core->session['domains_by_orgtype_id'][2]) == 1){?>
	<input type="hidden" name="domain_id" value="<?=$data['domain_id']?>" />
	<?}?>
	<input type="hidden" name="mnews_id" value="<?=$data['mnews_id']?>" />
	<? save_buttons(); ?>
</form>
