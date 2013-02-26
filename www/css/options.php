<?
$files = array(
  'fonts','tags','structure','nav','forms','catalog','headings','datatable','popups','rte','misc','slideshow','public',
);

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
print_r($options);
?>