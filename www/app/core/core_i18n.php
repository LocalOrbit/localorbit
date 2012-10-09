<?php 

class core_i18n
{
	public static function init()
	{
		global $core;
		
		# look for the dictionary specified in the user's session. if it doesn't exist, load up 
		# the application's default language (usually en-us)
		if(file_exists($core->paths['base'].'/dictionaries/'.$core->session['language'].'.php'))
			include($core->paths['base'].'/dictionaries/'.$core->session['language'].'.php');
		else
			if(file_exists($core->paths['base'].'/dictionaries/'.$core->config['default_language'].'.php'))
				include($core->paths['base'].'/dictionaries/'.$core->config['default_language'].'.php');
	}
	
	public static function deinit()
	{
		# don't need to do anything so far.
	}
	
	# this is used to load up a specific dictionary. Notably, it is NOT used for loading differenet languages,
	# but rather for loading fucntionality-specific dictionary, such as one for checkout, or profile management, etc
	#
	# the 'name' of the dictionary passed as parameter 0 is appended to a language code, so if you're trying to load
	# the
	function load_dictionary($name)
	{
		global $core;
		# look for a variant in the language specified in the user's session. if it doesn't exist, load up 
		# the application's default language (usually en-us)
		if(file_exists($core->paths['base'].'/dictionaries/'.$core->session['language'].'-'.$name.'.php'))
		{
			core::log('loading  custom dict: '.$core->paths['base'].'/dictionaries/'.$core->session['language'].'-'.$name.'.php');
			include($core->paths['base'].'/dictionaries/'.$core->session['language'].'-'.$name.'.php');
		}
		else
		{
			if(file_exists($core->paths['base'].'/dictionaries/'.$core->config['default_language'].'-'.$name.'.php'))
			{
				core::log('loading  custom dict: '.$core->paths['base'].'/dictionaries/'.$core->session['default_language'].'-'.$name.'.php');
				include($core->paths['base'].'/dictionaries/'.$core->config['default_language'].'-'.$name.'.php');
			}
		}
	}
	
	# this will only work when php > 5.3
	# for earlier version of php, use $core->i18n['phrase'] and $core->i18n($phrase,'param1','param2);
	public static function __callStatic($phrase,$parameters)
	{
		global $core;
		if(count($parameters) == 0)
		{
			return $core->i18n[$phrase];
		}
		else
		{
			$phrase = $core->i18n[$phrase];
			for ($i = 0; $i < count($parameters); $i++)
			{
				$phrase = str_replace('{'.$i.'}',$parameters[$i],$phrase);
			}
			return $phrase;
		}
	}
}

?>