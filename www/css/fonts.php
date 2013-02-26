<?
class core
{
  function __construct()
  {
    $this->config = array();
  }
}
global $core;
$core = new core();
$path = dirname(__FILE__);
include($path.'/../app/config.php');

$font_list = array();
mysql_connect($core->config['db']['hostname'],$core->config['db']['username'],$core->config['db']['password']);
mysql_select_db($core->config['db']['database']);
$fonts = mysql_query('select * from fonts;');
while ($font = mysql_fetch_assoc($fonts)) {
	list($font_name) = explode(',', $font['font_name']);
	$font_list[] = str_replace(' ', '+', str_replace('\'', '', $font_name));
}
$font_list = implode('|', $font_list);
header("Content-type: text/css; charset: UTF-8");
?>
@import url(<?=$_SERVER['HTTPS']?'https':'http'?>://fonts.googleapis.com/css?family=<?=$font_list?>);