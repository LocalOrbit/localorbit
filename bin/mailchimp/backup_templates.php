<?php
global $core;
define('__NO_OVERRIDE_ERROR__',true);
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();
core::load_library('mailchimp');

if(count($argv) < 2)
{
	exit("Usage: php -f backup_templates.php [source stage] [opt:template name]\nEx: php -f backup_templates.php production \n\tBy default, the script will backup all templates. If you want to backup only one, specify the name of the template you want to backup.\n");
}

$template_name = null;
if(count($argv) == 3)
{
	$template_name = $argv[3];
}


$output_path = dirname(__FILE__).'/../../etc/mailchimp_templates/';
echo('using key '.$core->config['mailchimp']['keys'][$argv[1]]."\n");
$source = new core_mailchimp($core->config['mailchimp']['keys'][$argv[1]]);

# get a list of the templates on both servers
$src_temps = $source->templates();
if ($source->errorCode){
	echo "Unable to Load Templates from Source!";
	echo "\n\tCode=".$source->errorCode;
	echo "\n\tMsg=".$source->errorMessage."\n";
}

# loop through the source templates
# if they exist on destination, update
# otherwise, create
foreach($src_temps as $type=>$type_list)
{
	foreach($type_list as $template)
	{
		# if we're only planning on 
		if(!is_null($template_name))
		{
			
			if($template_name == $template['name'])
			{
				echo("found ".$template['name']."\n");
				$info = $source->templateInfo($template['id']);
				#	$info['source']
				#   $template['name']
				
				file_put_contents($output_path.trim($template_name).'.html',$info['source']);		
				exit("\n");
			}
		}
		else
		{
			$info = $source->templateInfo($template['id']);
			echo("backing up ".$template['name']."\n");
			file_put_contents($output_path.trim($template['name']).'.html',$info['source']);
		}
	}
}
exit("done\n");
?>