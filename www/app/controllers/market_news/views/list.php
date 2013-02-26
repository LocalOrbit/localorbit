<?php
core::ensure_navstate(array('left'=>'left_dashboard'),'market_news-list','marketing');
core_ui::fullWidth();
core::head('Buy and Sell Local Food on Local Orbit - Market News','Market News.');
lo3::require_permission();
lo3::require_login();

$col = core::model('market_news')->collection();
$col->__model->autojoin(
	'left',
	'domains d',
	'(market_news.domain_id=d.domain_id)',
	array('d.name as domain_name')
);
$col->add_formatter('news_formatter');

$market_news = new core_datatable('market_news','market_news/list',$col);

if(lo3::is_admin() || lo3::is_market() && count($core->session['domains_by_orgtype_id'][2])>1)
{
	$hubs = core::model('domains')->collection()->sort('name');						
	if (lo3::is_market()) 
		$hubs = $hubs->filter('domain_id', 'in',$core->session['domains_by_orgtype_id'][2]);							
	
	$market_news->add_filter(new core_datatable_filter('market_news.domain_id'));
	echo(core_datatable_filter::make_select(
	'market_news',
	'market_news.domain_id',
	$market_news->filter_states['market_news__filter__market_news_domain_id'],
	$hubs,
	'domain_id',
	'name',
	'Show from all hubs'));
	}

core::replace('datatable_filters');
$market_news->filter_html .= core::getclear_position('datatable_filters');

if(lo3::is_market())
{
	# if this is a market manager, only show specials for their own hub
	$col->filter('market_news.domain_id','in', $core->session['domains_by_orgtype_id'][2]);
}
else if (!lo3::is_admin())
{
	# kick them out.
	lo3::require_orgtype('market');
}

function news_formatter($data)
{
	$data['content_stripped'] = strip_tags($data['content']);
	return $data;
}


$market_news->add(new core_datacolumn('creation_date','Date Published',true,'15%','{creation_date}','{creation_date}','{creation_date}'));
$market_news->add(new core_datacolumn('title','Title',true,'15%','<a href="#!market_news-edit--mnews_id-{mnews_id}">{title}</a>','{title}','{title}'));
$market_news->add(new core_datacolumn('hub','Hub',true,'15%','<a href="#!market_news-edit--mnews_id-{mnews_id}">{domain_name}</a>','{domain_name}','{domain_name}'));
$market_news->add(new core_datacolumn('content','Content',true,'43%','{content}','{content_stripped}','{content_stripped}'));
$market_news->add(new core_datacolumn('mnews_id',' ',false,'12%','<a class="btn btn-small btn-danger" href="#!market_news-list" onclick="if(confirm(\'Are you sure you want to delete this market news?\')){core.doRequest(\'/market_news/delete\',\'&mnews_id={mnews_id}\');return false;}"><i class="icon-minus" /> Delete</a>',' ',' '));
$market_news->columns[0]->autoformat='date-short';
page_header('Market News','#!market_news-edit','Create new news item', 'button',null, 'newspaper');
$market_news->sort_direction = 'desc';
$market_news->render();
?>