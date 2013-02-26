<?
function is_color ($value) {
  return preg_match('/^\s*#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})\s*$/', $value);
}

function format_value ($value) {
  return is_color($value) ? $value : "'" . $value . "'";
}

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
include(dirname(__FILE__) . '/../libraries/lessc.inc.php');# This is a list of all files we'll need to load

# connect to the database to query for values

mysql_connect($core->config['db']['hostname'],$core->config['db']['username'],$core->config['db']['password']);
mysql_select_db($core->config['db']['database']);

# the query should retrieve all default values, plus overrides on a per-domain basis
$sql = '
  select t.*,tor.override_value
  from template_options t
  left join template_option_overrides tor on (
    t.tempopt_id=tor.tempopt_id and tor.domain_id in (
      select domain_id
      from domains
      where hostname=\''.$_SERVER['HTTP_HOST'].'\'
    )
  );
';

$is_temp = (empty($_REQUEST['temp']) || $_REQUEST['temp'] === 'false') ? 0 : 1;

$result = mysql_query('select domain_id from domains where hostname = \'' . $_SERVER['HTTP_HOST'] . '\'');

$domain = mysql_fetch_assoc($result);

# build a hash of all options
$opts = mysql_query($sql);

$options = array();
while($opt = mysql_fetch_assoc($opts))
{
  # use the override if we find one
  if($opt['override_value'] == 'NULL' || is_null($opt['override_value']))
    $options[$opt['name']] = $opt['default_value'];
  else
    $options[$opt['name']] = $opt['override_value'];
}
//print_r($options);
$less = new lessc;

$branding = mysql_query('select * from domains_branding
  left join backgrounds on domains_branding.background_id = backgrounds.background_id
  left join fonts on domains_branding.header_font = fonts.font_id
  where domain_id = ' . $domain['domain_id'] . ' and is_temp = ' . $is_temp);
$branding = mysql_fetch_assoc($branding);

$options = array_map('format_value', $options);
if ($branding)
{
  $options['bodyBackground-image'] = $branding['file_name'] ?
    'url(/img/backgrounds/' . $branding['file_name'] . ') fixed' :
    'none';
  $options['bodyBackground'] = '#' . str_pad(dechex($branding['background_color']), 6, '0', STR_PAD_LEFT);
  $options['headingsFontFamily'] = $branding['font_name'];
  $options['mastercolor'] = '#' . str_pad(dechex($branding['text_color']), 6, '0', STR_PAD_LEFT);
  $options['headingLetterSpacing'] = isset($branding['kerning'])?$branding['kerning'].'px':'normal';
  $options['headingWordSpacing'] = isset($branding['kerning'])?(-$branding['kerning']).'px':'normal';
  
}
else
{
  $options['bodyBackground-image'] = 'url(/img/backgrounds/brownpaper.jpg) fixed';
  $options['headingsFontFamily'] = '"Open Sans Condensed","Domine", Georgia, "Times New Roman", Times, serif';
  $options['mastercolor'] = '#1f7169';
  $options['headingLetterSpacing'] = 'normal';
  $options['headingWordSpacing'] = 'normal';
}

$less->setVariables($options);
$less->setImportDir($path . '/../less');

header("Content-type: text/css; charset: UTF-8");

if ($_GET['which']):
	echo $less->compileFile($path . '/../less/bootstrap-tmp_' . $_GET['which'] . '.less');
else:
	echo $less->compileFile($path . '/../less/bootstrap.less');
endif;
?>