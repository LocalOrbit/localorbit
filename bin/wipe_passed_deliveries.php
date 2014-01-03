<?
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../www/app/core/core.php');
core::init();
ob_end_flush();

$config = array(
	'do-delete'=>0,
	'report-sql'=>0,
    'start-oid'=>25000,
);



array_shift($argv);
foreach($argv as $arg)
{
	$arg = explode(':',$arg);
	$config[$arg[0]] = str_replace('"','',$arg[1]);
}

mysql_query('SET SESSION group_concat_max_len = 1000000;');
$sql = '
    select group_concat(distinct(lo.lo_oid)) as oids
    from lo_order_deliveries lod
    inner join lo_order lo on (lo.lo_oid=lod.lo_oid)
    inner join delivery_days dd on (lod.dd_id=dd.dd_id)
    where (lod.delivery_start_time - (3600 * dd.hours_due_before)) < UNIX_TIMESTAMP(CURRENT_TIMESTAMP)
    and lo.ldstat_id=1
    and lo.lo_oid>'.$config['start-oid'].'
';


if($config['report-sql'] == '1')
{
    echo("$sql\n");
}
$passed_orders = core_db::col($sql,'oids');

if(isset($passed_orders) && $passed_orders != '')
{
    echo('need to delete '.substr_count($passed_orders,',')." orders.\n");
    $queries = array();
    $queries[] = 'delete from lo_fulfillment_order where lo_foid in (select lo_foid from lo_order_line_item where lo_oid in ('.$passed_orders.'));';
    $queries[] = 'delete from lo_order_line_item where lo_oid in ('.$passed_orders.');';
    $queries[] = 'delete from lo_order where lo_oid in ('.$passed_orders.');';
    $queries[] = 'delete from lo_order_deliveries where lo_oid in ('.$passed_orders.');';
    if($config['report-sql'] == '1')
    {
        print_r($queries);
    }
    if($config['do-delete'] == '1')
    {
        foreach($queries as $query)
        {
            core_db::query($query);
        }
    }
}
else
{
    exit("No orders to delete.\n");
}
exit("COMPLETE\n");
?>