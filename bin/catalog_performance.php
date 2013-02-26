<?php
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../www/app/core/core.php');
core::init();

$num_runs = 10;

ob_end_flush();
$start =microtime(true);
echo($start."\n");
for ($i=0; $i < $num_runs; $i++)
{ 
	core_db::query('FLUSH TABLES;');
	$prods = core::model('products')->get_catalog(17);
	foreach($prods as $prod)
	{	
		echo($prod['prod_id']."-");
	}
	echo("\n");
}

$end = microtime(true);
echo($end."\n");
echo("All: ".(($end - $start) / $num_runs)."\n");
// $start =microtime();
// for ($i=0; $i < 20; $i++) { 
// 	$dom_start =microtime();
// 	$prods = core::model('products')->get_catalog(1);
// 	foreach($prods as $prod)
// 	{
// 		$prod->__data['prod_id'] = $prod->__data['prod_id']+1;
// 	}
// 	$dom_end = microtime();
// 	echo($i.": ".($dom_end - $dom_start)."\n");
// }

// $end = microtime();
// echo("All: ".($end - $start)."\n");

?>