<?php

class core_logger
{
	public static function init()
	{
		global $core;
		
		# loop through all the possible log types and store
		# the file handles for them into an array
		foreach($core->config['log_types'] as $type)
		{
			$core->config['log_handles'][$type] = fopen($core->paths['logs'].'/'.$core->config['log_prefix'].$type.'.log','a');
		}
		
		core_logger::write('---------------------');
		core_logger::write('log started');
	}
	
	public static function write($string,$type='default')
	{
		global $core;
				
		# only write the log if the log type is enabled on the server
		if(isset($core->config['log_handles'][$type]))
		{
			# apply some slightly different rules to teh sql log
			# this ensures that you can copy/paste from the log direct to an 
			# sql terminal
			if($type == 'sql')
			{
				$time = '';
				$string = str_replace("\t",'  ',$string);
			}
			else
			{
				$time = substr(microtime(true),7,10);
				$time .= ': ';
			}
			fwrite($core->config['log_handles'][$type],$time.$string."\n");
		}
	}
	
	public static function deinit()
	{
		global $core;
		core_logger::write('---------------------');
		fclose($core->config['log_handles']['default']);
		fclose($core->config['log_handles']['sql']);
	}
}

?>