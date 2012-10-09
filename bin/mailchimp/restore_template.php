<?php
global $core;
define('__NO_OVERRIDE_ERROR__',true);
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();
core::load_library('mailchimp');

if(count($argv) < 3)
{
	exit("Usage: php -f move_templates.php [destination stage] [template name]\nEx: php -f restore_template.php production \"Weekly Fresh Sheet\"\n\t\n");
}

echo('using key '.$core->config['mailchimp']['keys'][$argv[1]]."\n");

$dest = new core_mailchimp($core->config['mailchimp']['keys'][$argv[1]]);
$template_name = trim($argv[2]);
$output_path = dirname(__FILE__).'/../../etc/mailchimp_templates/';


# get a list of the templates on the servers
$dest_temps = $dest->templates(array('user'=>true,'gallery'=>true,'base'=>true),array('include'=>false));
if ($dest->errorCode){
	echo "Unable to Load Templates from Destination!";
	echo "\n\tCode=".$dest->errorCode;
	echo "\n\tMsg=".$dest->errorMessage."\n";
}

# then build a hash of existing templates
# that way we can check if the template already exists on the destination

foreach($dest_temps as $type=>$type_list)
{
	foreach($type_list as $template)
	{
		#print_r($template);
		echo('checking '.$template['name']."\n");
		if(trim($template['name']) == trim($template_name))
		{
			echo("Restoring ".$template['id']."\n");
			#echo(file_get_contents($output_path.$template_name.'.html'));
			$dest->templateUpdate($template['id'],array(
				'name'=>$template_name,
				'html'=>file_get_contents($output_path.$template_name.'.html')
			));
			if ($dest->errorCode){
				echo "Unable to Load Templates from Destination!";
				echo "\n\tCode=".$dest->errorCode;
				echo "\n\tMsg=".$dest->errorMessage."\n";
			}
			exit("done\n");
			# perform the update
			
		}
	}
}
?>