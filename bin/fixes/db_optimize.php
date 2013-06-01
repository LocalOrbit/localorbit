<?php


define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();


$alltables = mysql_query("SHOW TABLES");

while ($table = mysql_fetch_assoc($alltables))
{
   foreach ($table as $db => $tablename)
   {
       echo("optimizing $tablename\n");
       mysql_query("OPTIMIZE TABLE `".$tablename."`;")
       or die(mysql_error());
   }
}


?>