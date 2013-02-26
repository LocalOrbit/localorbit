<?php
global $core;
define('__NO_OVERRIDE_ERROR__',true);
define('__CORE_ERROR_OUTPUT__','exit');
include(dirname(__FILE__).'/../../www/app/core/core.php');
core::init();
core::load_library('mailchimp');

if(count($argv) < 3)
{
	exit("Usage: php -f move_templates.php [source stage] [dest stage] [opt:template name]\nEx: php -f move_templates.php production testing\n\tBy default, the script will move all templates. If you want to move only one, specify the name of the template you want to move.\n");
}

$template_name = null;
if(count($argv) == 4)
{
	$template_name = $argv[3];
}



$source = new core_mailchimp($core->config['mailchimp']['keys'][$argv[1]]);
$dest   = new core_mailchimp($core->config['mailchimp']['keys'][$argv[2]]);

# get a list of the templates on both servers
$src_temps = $source->templates();
if ($source->errorCode){
	echo "Unable to Load Templates from Source!";
	echo "\n\tCode=".$source->errorCode;
	echo "\n\tMsg=".$source->errorMessage."\n";
}
$dest_temps = $dest->templates(array('user'=>true,'gallery'=>true,'base'=>true),array('include'=>false));
if ($dest->errorCode){
	echo "Unable to Load Templates from Destination!";
	echo "\n\tCode=".$dest->errorCode;
	echo "\n\tMsg=".$dest->errorMessage."\n";
}
$dest_by_name = array();



# then build a hash of existing templates
# that way we can check if the template already exists on the destination

foreach($dest_temps as $type=>$type_list)
{
	echo("checking types: ".$type."\n");
	foreach($type_list as $template)
	{
		echo("caching: ".$template['name']."\n");
		$dest_by_name[$template['name']] = $template;
	}
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
				
				if(empty($dest_by_name[$template['name']]))
				{
					echo("template ".$template['name']." does not exist on destination. creating\n");
					
					
					#print_r($info);
					$dest->templateAdd($template['name'],$info['source']);
					if ($dest->errorCode){
						echo "Unable to add template!";
						echo "\n\tCode=".$dest->errorCode;
						echo "\n\tMsg=".$dest->errorMessage."\n";
						
						# if we get back error 506, then we can try the super delete function
						if($dest->errorCode == 506)
						{
							echo("attempting the new fancy super-delete \n");
							#super_delete($template['name'],$dest);
							#
							#exit();
						}
					}
				}
				else
				{
					echo("template ".$template['name']." already exists on destination. updating\n");
					$dest->templateUpdate($dest_by_name[$template['name']]['id'],array('html'=>$info['source']));
					if ($dest->errorCode){
						echo "Unable to update template!";
						echo "\n\tCode=".$dest->errorCode;
						echo "\n\tMsg=".$dest->errorMessage."\n";
					}
				}
				
				exit("\n");
			}
		}
		else
		{
		 
		
			$info = $source->templateInfo($template['id']);
			if(empty($dest_by_name[$template['name']]))
			{
				echo("template ".$template['name']." does not exist on destination. creating\n");
				
				
				#print_r($info);
				$dest->templateAdd($template['name'],$info['source']);
				if ($dest->errorCode){
					echo "Unable to add template!";
					echo "\n\tCode=".$dest->errorCode;
					echo "\n\tMsg=".$dest->errorMessage."\n";
					
					# if we get back error 506, then we can try the super delete function
					if($dest->errorCode == 506)
					{
						echo("attempting the new fancy super-delete \n");
						#super_delete($template['name'],$dest);
						#
						#exit();
					}
				}
			}
			else
			{
				echo("template ".$template['name']." already exists on destination. updating\n");
				$dest->templateUpdate($dest_by_name[$template['name']]['id'],array('html'=>$info['source']));
				if ($dest->errorCode){
					echo "Unable to update template!";
					echo "\n\tCode=".$dest->errorCode;
					echo "\n\tMsg=".$dest->errorMessage."\n";
				}
			}
		}
	}
}

# now loop through all source templates. Create them as necessary
foreach($src_temps as $type=>$type_list)
{
	foreach($type_list as $template)
	{
		$info = $source->templateInfo($template['id']);
		if(empty($dest_by_name[$template['name']]))
		{
			echo("template ".$template['name']." does not exist on destination. creating\n");
			
			
			#print_r($info);
			$dest->templateAdd($template['name'],$info['source']);
			if ($dest->errorCode){
				echo "Unable to add template!";
				echo "\n\tCode=".$dest->errorCode;
				echo "\n\tMsg=".$dest->errorMessage."\n";
				
				# if we get back error 506, then we can try the super delete function
				if($dest->errorCode == 506)
				{
					echo("attempting the new fancy super-delete \n");
					#super_delete($template['name'],$dest);
					#
					#exit();
				}
			}
		}
		else
		{
			echo("template ".$template['name']." already exists on destination. updating\n");
			$dest->templateUpdate($dest_by_name[$template['name']]['id'],array('html'=>$info['source']));
			if ($dest->errorCode){
				echo "Unable to update template!";
				echo "\n\tCode=".$dest->errorCode;
				echo "\n\tMsg=".$dest->errorMessage."\n";
			}
		}
	}
}
?>