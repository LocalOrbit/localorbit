<?php

function lo3_display_negative($input)
{
	$input = floatval($input);
	return abs($input);
}

function lo3_parse_negative($input)
{
}

function parse_date($input)
{
	preg_match_all('/([A-Z][a-z][a-z]).(\d+)\,.(\d\d\d\d)/',$input,$matches);
	#core::log(print_r($matches,true));
	$months = array(
		'Jan'=>'01',
		'Feb'=>'02',
		'Mar'=>'03',
		'Apr'=>'04',
		'May'=>'05',
		'Jun'=>'06',
		'Jul'=>'07',
		'Aug'=>'08',
		'Sep'=>'09',
		'Oct'=>'10',
		'Nov'=>'11',
		'Dec'=>'12',
	);
	return $matches[3][0].'-'.$months[$matches[1][0]].'-'.str_pad($matches[2][0],2,'0',STR_PAD_LEFT).' 15:00:00';
}

function parse_dates()
{
	global $core;
	$dates = func_get_args();
	foreach($dates as $date)
	{
		$core->data[$date] = parse_date($core->data[$date]);
	}
}

?>