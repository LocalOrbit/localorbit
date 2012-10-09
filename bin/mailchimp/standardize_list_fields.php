<?php


function reset_flags()
{
	global $core;
	foreach($core->config['mailchimp']['fields'] as $tag=>$array)
		$core->config['mailchimp']['fields'][$tag][5] = false;
}

# load up stuff
global $core;
define('__NO_OVERRIDE_ERROR__',true);
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();
core::load_library('mailchimp');
$mc = new core_mailchimp();
ob_end_clean();




echo("starting sync using key ".$mc->key."\n");

foreach($core->config['mailchimp']['lists'] as $list)
{
	# reset the flags we use to keep track of which fields are in the current list
	reset_flags();
	
	# get the list of fields for the list by name
	$id = $mc->get_list_id($list);
	echo("loading $id:$list\n");
	
	# if teh list doesn't exist at all, create it
	if($id === 0)
	{
		echo("=====CANNOT SYNC THIS LIST. CREATE VIA WEBSITE FIRST=====");
		exit();
	}
	$lfields = $mc->listMergeVars($id);
	
	# determine which fields this list already has 
	echo("\t");
	foreach($lfields as $lfield)
	{
		$core->config['mailchimp']['fields'][$lfield['tag']][5] = true;
		echo($lfield['tag'].",");
		#echo("\t'".$lfield['tag']."'=>array('".$lfield['tag']."','".$lfield['name']."','".$lfield['field_type']."'),\n");
	}
	echo("\n");
	
	# loop through all the fields that SHOULD be in the list
	echo("----------------------------------\n");
	foreach($core->config['mailchimp']['fields'] as $tag=>$field)
	{
		#echo("\t\tchecking ".$tag.": ".$field[5]."\n");
		# if the field isn't there, add it.
		if($field[5] === false)
		{
			echo("\n\tneed to add ".$field[0]." to ".$list."\n");
			$success = $mc->listMergeVarAdd($id,$field[0],$field[1],array(
				'field_type'=>$field[2]
			));
			if($success)
			{
				echo("\tfield add success!\n");
			}
			else
			{
				echo("\tfield add FAIL FAIL FAIL!\n");
			}
		}
	}
	echo("----------------------------------\n");
}

?>