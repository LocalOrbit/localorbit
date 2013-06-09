<?php

$lines = explode("\n",file_get_contents($argv[1]));
$errors = array(
	'X42'=>'Routing No/Check Digit Error  ENR only',    # user probably inverted their routing/account #
	'XA7'=>'Credits not allowed for this service code', # used WEB, PPD, or CCD when it should have been PPD or CCD
	'XA3'=>'amount over limit',
	'XA8'=>'Duplicate Item',
);


$action_details = array();
foreach($lines as $line)
{
	$info = unserialize($line);
	#print_r($info);
	
	if(
		$info->ResponseCode == '4INT'
		||
		$info->ResponseCode == '3RET'
	)
	{
		echo("Got a problem wtih ".$info->FrontEndTrace.": ".$errors[trim($info->ActionDetail)]."\n");
		print_r($info);	
	}
}
?> 