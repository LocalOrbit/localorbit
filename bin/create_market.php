#!/usr/bin/php
<?php

global $core;

define('__NO_OVERRIDE_ERROR__',true);
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../www/app/core/core.php');
core::init();
ob_end_flush();


$config = array(
	'report-sql'=>0,
	'hostname'=>'',
	'name'=>'',
	'mm_fname'=>'',
	'mm_lname'=>'',
	'mm_email'=>'',
	'mm_name'=>'',
);
array_shift($argv);
foreach($argv as $arg)
{
	$arg = explode(':',$arg);
	$config[$arg[0]] = str_replace('"','',$arg[1]);
}

echo("Executing with config: \n");
print_r($config);
echo("\n");

$org = core::model('organizations')
	->import(array(
		'name'=>$config['mm_name'],
		'is_active'=>1,
		'is_enabled'=>1,
	));
$org->__orig_data = array();
$org->save();
$user = core::model('customer_entity')
	->import(array(
		'first_name'=>$config['mm_fname'],
		'last_name'=>$config['mm_lname'],
		'email'=>$config['mm_email'],
		'org_id'=>$org['org_id'],
		'is_active'=>1,
		'is_enabled'=>1,
	));
$user->__orig_data = array();
$user->save();
$domain = core::model('domains')
	->import(array(
		'name'=>$config['name'],
		'hostname'=>$config['hostname'],
	));
$domain->__orig_data = array();
$domain->save();

core_db::query('
	insert into organizations_to_domains 
		(org_id,domain_id,orgtype_id,is_home)
	values ('.$org['org_id'].','.$domain['domain_id'].',2,1);
');

exit("to complete, do this: \ncd ../www/img/; mkdir ".$domain['domain_id'].";chmod 777 ".$domain['domain_id'].";\n");

?>