#!/usr/bin/php
<?php

# basic sectup
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../www/app/core/core.php');
core::init();
ob_end_flush();

$config = array(
	'lo-oid'=>0,  # allows you to restrict the query to a single vendor
	'report-sql'=>0,
	'do-delete'=>0,
);

array_shift($argv);
foreach($argv as $arg)
{
	$arg = explode(':',$arg);
	$config[$arg[0]] = str_replace('"','',$arg[1]);
}

$lo_oid = $config['lo-oid'];

$sql = array(
	"
		delete from payables 
		where payable_type in ('buyer order','seller order','hub fees','lo fees') 
		and parent_obj_id in (
			select lo_liid 
			from lo_order_line_item where lo_oid=$lo_oid
		);
	",
	"
		delete from payables 
		where payable_type in ('delivery fee') 
		and parent_obj_id =$lo_oid;
	",
	"delete from lo_fulfillment_order where lo_foid in (
		select lo_foid 
		from lo_order_line_item where lo_oid=$lo_oid
	);",
	"delete from lo_order_deliveries where lo_oid=$lo_oid;",
	"delete from lo_order_line_item where lo_oid=$lo_oid;",
	"delete from lo_order where lo_oid=$lo_oid;"
);

echo("preparing to delete $lo_oid\n");
if($config['report-sql'] == 1)	echo("\n\n".print_r($sql,true)."\n\n");


if($config['do-delete'] == 1)
{
	foreach($sql as $query)
		mysql_query($query);
	echo("DELETE COMPLETE\n");
}
else
{
	echo("NOT ACTUALLY DELETING\nIn order to actually delete the order, use this parameter: do-delete:1\n");
}

exit();
?>