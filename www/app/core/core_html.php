<?php
# this is intended in the future to be an html generation library.
# it's empty so far, but someday!!

class core_html
{
	public static function __callStatic($method,$params)
	{
		core::log('called: '.$method);
	}
}

?>