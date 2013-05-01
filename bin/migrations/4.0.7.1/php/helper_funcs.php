<?php

function get_array($sql)
{
	$return = array();
	$results = mysql_query($sql);
	while($return[] = mysql_fetch_assoc($results));
	array_pop($return);
	return $return;
}

function get_array_fields($in_array,$field)
{
	$results = array();
	foreach($in_array as $row)
	{
		$results[] = $row[$field];
	}
	return $results;
}

function make_insert($table,$data)
{
	$sql = 'insert into '.$table.' ('.implode(',',array_keys($data)).')';
	$sql .= ' values (\''.implode("','",array_values($data)).'\');';
	return $sql;
}

?>