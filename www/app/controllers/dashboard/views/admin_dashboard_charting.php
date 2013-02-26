<?
core::ensure_navstate(array('left'=>'left_dashboard'));
core_ui::fullWidth();
core_ui::load_library('js','test.js');
core_ui::load_library('js','excanvas.min.js');
#core_ui::load_library('js','jquery.jqplot.min.js');
core_ui::load_library('css','jquery.jqplot.min.css');

core_ui::load_library('js',"jqplot_plugins/jqplot.barRenderer.js");
core_ui::load_library('js',"jqplot_plugins/jqplot.highlighter.js");
core_ui::load_library('js',"jqplot_plugins/jqplot.cursor.js");
core_ui::load_library('js',"jqplot_plugins/jqplot.pointLabels.js");
core_ui::load_library('js',"jqplot_plugins/jqplot.dateAxisRenderer.min.js");

$today = explode('-',date('m-d-Y'));
$yesterday_start = mktime(0,0,0,intval($today[0]),intval($today[1]),intval($today[2]));
$yesterday_end   = $yesterday_start + 86399;
$last7_start     = $yesterday_start - (86400*6);
$last7_end       = $yesterday_end;
$last30_start    = $yesterday_start - (86400*29);
$last30_end      = $yesterday_end;

$data = array(
	'orgs'=>array(),
	'num_trans'=>array(),
	'dol_trans'=>array(),
);

$exclude_sql = ' and domain_id not in (3,6)';



$data['orgs'][0] = core_db::col('select count(org_id) as mycount from organizations where UNIX_TIMESTAMP(creation_date) >= '.$yesterday_start.' and UNIX_TIMESTAMP(creation_date) <= '.$yesterday_end.' '.$exclude_sql,'mycount');
$data['orgs'][1] = core_db::col('select count(org_id) as mycount from organizations where UNIX_TIMESTAMP(creation_date) >= '.$last7_start.' and UNIX_TIMESTAMP(creation_date) <= '.$last7_end.' '.$exclude_sql,'mycount');
$data['orgs'][2] = core_db::col('select count(org_id) as mycount from organizations where UNIX_TIMESTAMP(creation_date) >= '.$last30_start.' and UNIX_TIMESTAMP(creation_date) <= '.$last30_end.' '.$exclude_sql,'mycount');
$data['orgs'][3] = core_db::col('select count(org_id) as mycount from organizations where org_id>0 '.$exclude_sql,'mycount');

$data['num_trans'][0] = core_db::col('select count(lo_oid) as mycount from lo_order where UNIX_TIMESTAMP(order_date) >= '.$yesterday_start.' and UNIX_TIMESTAMP(order_date) <= '.$yesterday_end.' '.$exclude_sql,'mycount');
$data['num_trans'][1] = core_db::col('select count(lo_oid) as mycount from lo_order where UNIX_TIMESTAMP(order_date) >= '.$last7_start.' and UNIX_TIMESTAMP(order_date) <= '.$last7_end.' '.$exclude_sql,'mycount');
$data['num_trans'][2] = core_db::col('select count(lo_oid) as mycount from lo_order where UNIX_TIMESTAMP(order_date) >= '.$last30_start.' and UNIX_TIMESTAMP(order_date) <= '.$last30_end.' '.$exclude_sql,'mycount');
$data['num_trans'][3] = core_db::col('select count(lo_oid) as mycount from lo_order where org_id>0 '.$exclude_sql,'mycount');

$data['dol_trans'][0] = core_db::col('select sum(grand_total) as mycount from lo_order where UNIX_TIMESTAMP(order_date) >= '.$yesterday_start.' and UNIX_TIMESTAMP(order_date) <= '.$yesterday_end.' '.$exclude_sql,'mycount');
$data['dol_trans'][1] = core_db::col('select sum(grand_total) as mycount from lo_order where UNIX_TIMESTAMP(order_date) >= '.$last7_start.' and UNIX_TIMESTAMP(order_date) <= '.$last7_end.' '.$exclude_sql,'mycount');
$data['dol_trans'][2] = core_db::col('select sum(grand_total) as mycount from lo_order where UNIX_TIMESTAMP(order_date) >= '.$last30_start.' and UNIX_TIMESTAMP(order_date) <= '.$last30_end.' '.$exclude_sql,'mycount');
$data['dol_trans'][3] = core_db::col('select sum(grand_total) as mycount from lo_order where lo_oid>0 '.$exclude_sql,'mycount');

$reg_data = new core_collection('
	select count(org_id)  as datecount,floor(UNIX_TIMESTAMP(creation_date) / 86400)  as mydate
	from organizations
	where UNIX_TIMESTAMP(creation_date) >= '.$last30_start .' 
	group by floor(UNIX_TIMESTAMP(creation_date) / 86400)');
$reg_data = $reg_data->to_array();
for ($i = 0; $i < count($reg_data); $i++)
{
	$reg_data[$i]['mydate'] = $reg_data[$i]['mydate'] * 86400;
	$reg_data[$i]['mydate'] = date('d-M-y',$reg_data[$i]['mydate']);
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

<h2>Metrics</h2>

<table class="table table-striped">
	<thead>
		<tr>
			<th class="dt">Data Type</th>
			<th class="dt" style="text-align: center">Yesterday</th>
			<th class="dt" style="text-align: center">Last 7 Days</th>
			<th class="dt" style="text-align: center">Last 30 days</th>
			<th class="dt" style="text-align: center">All Time</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td><h2>New Organizations</h2></td>
			<td style="text-align: center"><?=$data['orgs'][0]?></td>
			<td style="text-align: center"><?=$data['orgs'][1]?></td>
			<td style="text-align: center"><?=$data['orgs'][2]?></td>
			<td style="text-align: center;font-weight:bold;"><?=$data['orgs'][3]?></td>
		</tr>
		<tr>
			<td><h2># of Transactions</h2></td>
			<td style="text-align: center"><?=$data['num_trans'][0]?></td>
			<td style="text-align: center"><?=$data['num_trans'][1]?></td>
			<td style="text-align: center"><?=$data['num_trans'][2]?></td>
			<td style="text-align: center;font-weight:bold;"><?=$data['num_trans'][3]?></td>
		</tr>
		<tr>
			<td><h2>$ value of Transactions</h2></td>
			<td style="text-align: center"><?=core_format::price($data['dol_trans'][0])?></td>
			<td style="text-align: center"><?=core_format::price($data['dol_trans'][1])?></td>
			<td style="text-align: center"><?=core_format::price($data['dol_trans'][2])?></td>
			<td style="text-align: center;font-weight:bold;"><?=core_format::price($data['dol_trans'][3])?></td>
		</tr>
	</tbody>
</table>

<?=core_ui::tab_switchers('charttabs',array('New Organizations, 30 days','New Orders, 30 days'))?>
<div class="tabarea" id="charttabs-a1">
	<div id="chart1" style="width:740px; height:300px"></div>
</div>
<div class="tabarea" id="charttabs-a2">
	<div id="chart2" style="width:740px; height:300px"></div>
</div>
<? core::replace('center');?>
window.setTimeout(function(){
 var line1 = [
<?
for ($i = 0; $i < count($reg_data); $i++)
{
	echo(($i == 0)?'':',');
	echo("['".$reg_data[$i]['mydate']."',".intval($reg_data[$i]['datecount'])."]");
}
?>
 ];
  var plot1 = $.jqplot('chart1', [line1], {
      title:'',
      axes:{
        xaxis:{
          renderer:$.jqplot.DateAxisRenderer,
          tickOptions:{
            formatString:'%b&nbsp;%#d'
          } 
        },
        yaxis:{

        }
      },
      highlighter: {
        show: true,
        sizeAdjust: 7.5
      },
      cursor: {
        show: false
      }
  });

 
},1500);
window.setTimeout(function(){
	var line2 = [
<?
for ($i = 0; $i < count($ord_data); $i++)
{
	echo(($i == 0)?'':',');
	echo("['".$ord_data[$i]['mydate']."',".intval($ord_data[$i]['datecount'])."]");
}
?>
 ];
  var plot2 = $.jqplot('chart2', [line2], {
      title:'',
      axes:{
        xaxis:{
          renderer:$.jqplot.DateAxisRenderer,
          tickOptions:{
            formatString:'%b&nbsp;%#d'
          } 
        },
        yaxis:{

        }
      },
      highlighter: {
        show: true,
        sizeAdjust: 7.5
      },
      cursor: {
        show: false
      }
  });
},3000);
<? core::js(); ?>