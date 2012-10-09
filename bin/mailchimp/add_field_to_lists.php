<?php

# change to be the day before
# change query to ONLY send to  wholesale buyers 

define('__NO_OVERRIDE_ERROR__',true);
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();
core::load_library('mailchimp');
$mc = new core_mailchimp();

if(count($argv) != 3)
{
	exit("not enough args. use: php -f add_field_to_lists.php tagname humanname\n");
}

echo("tag:    ".$argv[1]."\n");
echo("name:   ".$argv[2]."\n");


echo("--------------------\n");

$names = array('production','qa','testing');
$servers = array();

for ($i = 0; $i < count($names); $i++)
{
	echo("connecting to ".$names[$i].": ".$lomc->keys[$names[$i]]."\n");
	$servers[$names[$i]] = new MCAPI($lomc->keys[$names[$i]]);
	#print_r($servers[$names[$i]]);
}

echo("--------------------\n");
for ($i = 0; $i < count($names); $i++)
{
	for ($k = 0; $k < count($lomc->lists); $k++)
	{
		echo("\tadding field to ".$lomc->lists[$k].' to '.$names[$i]."\n");
		echo("\t\tlist id: ".$lomc->list_ids[$lomc->lists[$k]][$names[$i]]."\n");
		if($lomc->list_ids[$lomc->lists[$k]][$names[$i]] != '')
		{
			
		
			trY
			{
				$servers[$names[$i]]->listMergeVarAdd(
					$lomc->list_ids[$lomc->lists[$k]][$names[$i]],
					$argv[1],
					$argv[2],
					array(
						'field_type'=>'text',
						'req'=>false,
					)
				);
			}
			catch(Exception $e)
			{
				echo("exception caught :/ \n");
			}
			
			# echo('passed listMergeVarAdd');
/*
			
			if ($servers[$names[$i]]->errorCode){
				exit("==== Unable to unsubscribe users \n: ".$servers[$names[$i]]->errorCode.':'.$servers[$names[$i]]->errorMessage."\n");
			} else {
			}
*/
		}
		
	}
	
}

?>