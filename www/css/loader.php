<?php
# This is a list of all files we'll need to load
$files = array(
	#'fonts','tags','structure','nav','forms','catalog','headings','datatable','popups','rte','misc','slideshow','public',
	'forms','datatable','popups','rte', 'chosen'
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

# set the header an start processing code files
header('Content-type: text/css');

# now load all the different css files
foreach($files as $file)
{
	include($path.'/'.$file.'.css');
}

/*
 *  below is old stuff, no longer necessary since all settings are now in db
 *
 *
# general color defs
$options['p1a'] = '#e5edeb'; # this is the lightest green
$options['p1b'] = '#e3eae7'; # this is the very light green
$options['p1c'] = '#8eb9bb'; # light medium green
$options['p1d'] = '#a7beb4'; # this is a medium green
$options['p1e'] = '#6c9887'; # this is a slightly dark medium green
$options['p1f'] = '#498e91'; # dark green
*
*
$options['p2b'] = '#b64956'; # lighter red
$options['p2c'] = '#912529'; # darker red

$options['p3a'] = '#f9eeb4'; # lighter yellow
$options['p3b'] = '#ead574'; # medium yellow
$options['p3c'] = '#cb9e39'; # dark yellow

$options['p4a'] = '#f3f3f3';
$options['p4b'] = '#ccc';
$options['p4c'] = '#777';
$options['p4d'] = '#333';
$options['p4e'] = '#222';

$options['p4f'] = '#fff';

# area-specific color defs (might use above defs rather than custom colors)
$options['p1e'] = $options['p1e'];
$options['p4f'] = $options['p4f'];
$options['p4d']    = $options['p4d']; # for light backgrounds
$options['p4f']    = $options['p4f']; # for dark backgrounds
$options['p2b']     = $options['p2b'];

$options['font1']     = 'Ubuntu';
$options['font-size'] = '14pt';
*/








?>
