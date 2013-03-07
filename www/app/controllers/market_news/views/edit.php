<?php
core::ensure_navstate(array('left'=>'left_dashboard'),'market_news-list','marketing');
core_ui::fullWidth();
core::head('Buy and Sell Local Food on Local Orbit - Edit Market News','This page is used to edit Market News');
lo3::require_permission();
lo3::require_login();

# get a filtered list of domains that the current user can create news on
$hubs = core::model('domains')->collection()->sort('name');						
if (lo3::is_market()) { 
	$hubs = $hubs->filter('domain_id', 'in', implode(',', $core->session['domains_by_orgtype_id'][2]));							
} 

# load the data and rules
$data = (is_numeric($core->data['mnews_id']))?core::model('market_news')->load():array('domain_id'=>$core->config['domain']['domain_id']);
$this->rules()->js();

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

# write the form
echo(
	core_form::page_header('Editing '.$data['title'],'#!market_news-list','cancel', 'cancel').
	core_form::form('marketnewsform','/market_news/update',null,
		core_form::tab_switchers('marketnewstabs',array('Market News')),
		core_form::tab('marketnewstabs',
			core_form::table_nv(
				(lo3::is_admin() || count($core->session['domains_by_orgtype_id'][2])>1)?
					core_form::input_select('Hub','domain_id',$data,$hubs,array(
						'default_show'=>true,
						'default_text'=>'Select a Hub',
						'text_column'=>'name',
						'value_column'=>'domain_id',
					))
				:'',
				core_form::input_text('Title','title',$data),
				core_form::input_rte('Content','content',$data,array('class' => 'input-xxlarge'))
			)
		),
		(count($core->session['domains_by_orgtype_id'][2]) == 1)?core_form::input_hidden('domain_id',$core->session['domains_by_orgtype_id'][2][0]):'',
		core_form::input_hidden('mnews_id',$data),
		core_form::save_buttons()
	)
);
?>