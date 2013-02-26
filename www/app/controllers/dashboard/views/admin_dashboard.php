<?

#$results = core::model('customer_entity')->get_domain_permissions($core->session['org_id']);
#echo('<pre>');
#echo(print_r($results,true));
#echo('</pre><br />');
/*
echo('<h1>home domain is: '.$core->session['home_domain_id'].'</h1>Domain ids: ');
echo('<pre>');
echo(print_r($core->session['domains_by_orgtype_id'],true));
echo('</pre><br />');
echo('<pre>');
echo(print_r($core->session['all_domains'],true));
echo('</pre><br />');
*/

core::ensure_navstate(array('left'=>'left_dashboard'));
core_ui::fullWidth();
//~ core_ui::load_library('js','test.js');
//~ core_ui::load_library('js','excanvas.min.js');
//~ #core_ui::load_library('js','jquery.jqplot.min.js');
//~ core_ui::load_library('css','jquery.jqplot.min.css');
//~
//~ core_ui::load_library('js',"jqplot_plugins/jqplot.barRenderer.js");
//~ core_ui::load_library('js',"jqplot_plugins/jqplot.highlighter.js");
//~ core_ui::load_library('js',"jqplot_plugins/jqplot.cursor.js");
//~ core_ui::load_library('js',"jqplot_plugins/jqplot.pointLabels.js");
//~ core_ui::load_library('js',"jqplot_plugins/jqplot.dateAxisRenderer.min.js");

#echo('<pre>');
#print_r($core->session);
$today = explode('-',date('m-d-Y',  time() + $core->config['domain']['offset_seconds']));

$yesterday_end = mktime((($core->config['domain']['offset_seconds'] / 3600) * -1),0,0,intval($today[0]),intval($today[1]),intval($today[2]));
$yesterday_start   = $yesterday_end - 86399;
$today_start     = $yesterday_end + 1;
$today_end       = $today_start + 86400;
$last7_start     = $yesterday_start - (86400*6);
$last7_end       = $yesterday_end;
$last30_start    = $yesterday_start - (86400*29);
$last30_end      = $yesterday_end;
$last60_start    = $last30_start - (29*86400);
$last60_end      = $last30_end   - (29*86400);


#echo($today_start . ' / 1341841062 / ' .$today_end);
#echo(date('Y-m-d H:i:s',$yesterday_start).'<br />');
#echo(date('Y-m-d H:i:s',$yesterday_end).'<br />');

$data = array(
	'orgs'=>array(),
	'num_trans'=>array(),
	'dol_trans'=>array(),
);

$exclude_sql = ' and domain_id not in (1,3,6,23,24,25,26)';
$status_exclude = ' where ldstat_id not in (select ldstat_id from lo_delivery_statuses where delivery_status in (\'Cart\',\'Canceled\'))';
$cycle_data = $this->get_cycle_numbers($status_exclude);


$reg_data = new core_collection('
	select count(organizations.org_id)  as datecount,floor(UNIX_TIMESTAMP(creation_date) / 86400)  as mydate
	from organizations
	where UNIX_TIMESTAMP(creation_date) >= '.$last30_start .'
	group by floor(UNIX_TIMESTAMP(creation_date) / 86400)');
$reg_data = $reg_data->to_array();
for ($i = 0; $i < count($reg_data); $i++)
{
	#$reg_data[$i]['mydate'] = $reg_data[$i]['mydate'] * 86400;
	#$reg_data[$i]['mydate'] = date('d-M-y',$reg_data[$i]['mydate']);
}

$ord_data = new core_collection('
	select count(lo_oid)  as datecount,floor(UNIX_TIMESTAMP(order_date) / 86400)  as mydate
	from lo_order
	where UNIX_TIMESTAMP(order_date) >= '.$last30_start .'
	group by floor(UNIX_TIMESTAMP(order_date) / 86400)');
$ord_data = $ord_data->to_array();
for ($i = 0; $i < count($ord_data); $i++)
{
	$ord_data[$i]['mydate'] = $ord_data[$i]['mydate'] * 86400;
	$ord_data[$i]['mydate'] = date('d-M-y',$ord_data[$i]['mydate']);
}
?>
<h1>Welcome <?=$core->session['first_name']?> <?=$core->session['last_name']?></h1>

<p>You are currently logged into Local orbit as an administrator. This gives you the right to do pretty much anything you want, such as <a href="#!market-list">configure a hub</a>, <a href="#!products-list">modify a product</a>, <a href="#!organizations-create">create a new customer company</a>, or <a href="#!dictionaries-edit">modify the dictionary</a>.</p>
<p>Remember though: With great power, comes bad movie quotes. And remember that Mike Thorn can undo *almost* anything. Be careful.</p>

<div class="row">
<div class="span6">

<h2>7 Day Cycle</h2>

<table class="table table-striped">
	<thead>
		<tr>
			<th class="dt">Type</th>
			<th class="dt" style="text-align: right">Today</th>
			<th class="dt" style="text-align: right">Yesterday</th>
			<th class="dt" style="text-align: right">This week</th>
			<th class="dt" style="text-align: right">Last week</th>
			<th class="dt" style="text-align: right">2 weeks ago</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>Sales</td>
			<td style="text-align: right"><?=core_format::price($cycle_data['day'][0])?></td>
			<td style="text-align: right"><?=core_format::price($cycle_data['day'][1])?></td>
			<td style="text-align: right"><?=core_format::price($cycle_data['week'][0])?></td>
			<td style="text-align: right"><?=core_format::price($cycle_data['week'][1])?></td>
			<td style="text-align: right"><?=core_format::price($cycle_data['week'][2])?></td>
		</tr>
		<tr>
			<td>Hub Fees</td>
			<td style="text-align: right"><?=core_format::price($cycle_data['day'][3])?></td>
			<td style="text-align: right"><?=core_format::price($cycle_data['day'][4])?></td>
			<td style="text-align: right"><?=core_format::price($cycle_data['week'][3])?></td>
			<td style="text-align: right"><?=core_format::price($cycle_data['week'][4])?></td>
			<td style="text-align: right"><?=core_format::price($cycle_data['week'][5])?></td>
		</tr>
		<tr>
			<td>LO Fees</td>
			<td style="text-align: right"><?=core_format::price($cycle_data['day'][6])?></td>
			<td style="text-align: right"><?=core_format::price($cycle_data['day'][7])?></td>
			<td style="text-align: right"><?=core_format::price($cycle_data['week'][6])?></td>
			<td style="text-align: right"><?=core_format::price($cycle_data['week'][7])?></td>
			<td style="text-align: right"><?=core_format::price($cycle_data['week'][8])?></td>
		</tr>
	</tbody>
</table>

</div>
<div class="span6">

<h2>Month Cycle</h2>

<table class="table table-striped">
	<thead>
		<tr>
			<th class="dt">Type</th>
			<th class="dt" style="text-align: right">This month</th>
			<th class="dt" style="text-align: right">Last month</th>
			<th class="dt" style="text-align: right">2 months ago</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>Sales</td>
			<td style="text-align: right"><?=core_format::price($cycle_data['month'][0])?></td>
			<td style="text-align: right"><?=core_format::price($cycle_data['month'][1])?></td>
			<td style="text-align: right"><?=core_format::price($cycle_data['month'][2])?></td>
		</tr>
		<tr>
			<td>Hub Fees</td>
			<td style="text-align: right"><?=core_format::price($cycle_data['month'][3])?></td>
			<td style="text-align: right"><?=core_format::price($cycle_data['month'][4])?></td>
			<td style="text-align: right"><?=core_format::price($cycle_data['month'][5])?></td>
		</tr>
		<tr>
			<td>LO Fees</td>
			<td style="text-align: right"><?=core_format::price($cycle_data['month'][6])?></td>
			<td style="text-align: right"><?=core_format::price($cycle_data['month'][7])?></td>
			<td style="text-align: right"><?=core_format::price($cycle_data['month'][8])?></td>
		</tr>
	</tbody>
</table>

</div>
</div>