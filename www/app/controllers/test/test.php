
<?php
try {
	
	global $core;

	$int = 1386705600;	
	echo "<br>";
	echo date('Y-m-d H:i:s',time());
	
	
	echo "<br>";
	echo date('Y-m-d H:i:s',$int);

	echo "22222222222222 " . $core->session['time_offset'];

} catch (Exception $e) {
	echo($e->getMessage().'<pre>'.$e->getTraceAsString().'</pre>');
}

echo "<br>";
	echo "<br>";
?>

Example 01:

<?php
	echo "<br>";

date_default_timezone_set("UTC");

$dftz011 = date_default_timezone_get();

echo '<br><b>' . $dftz011 . '</b><br><br>';

$dtms011 = new DateTime();

$dtms011->setTimestamp(1386705600);
echo $dtms011->format('B => (U) => T Y-M-d H:i:s');

echo "<br>";
date_timestamp_set($dtms011, 1377705600);
echo date_format($dtms011, 'B => (U) => T Y-M-d H:i:s');

?>

Example 02:

<?php

echo "<br>";
date_default_timezone_set("America/New_York");

$dftz021 = date_default_timezone_get();

echo '<br><b>' . $dftz021 . '</b><br><br>';

$dtms021 = date_create();

date_timestamp_set($dtms021, 1386705600);

echo date_format($dtms021, 'B => (U) => T Y-M-d H:i:s');

echo "<br>";
date_timestamp_set($dtms021, 1377705600);
echo date_format($dtms021, 'B => (U) => T Y-M-d H:i:s');


echo "<br>".date("I", 1386705600);
echo "<br>".date("I", 1377705600);



?>