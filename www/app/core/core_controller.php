<?php

class core_controller 
{
	function __construct($path)
	{
		#core::log('default controller constructor called: '.get_class($this).'/'.$path);
		$this->path = $path;
		$this->i18n = array();
		$this->rules = array();
	}
	
	
	
	
	
	function __call($method,$params)
	{
		global $core;
		
		$view = $this->path.'views/'.$method.'.php';
		core::log('trying to load '.$view);
		if(file_exists($view))
		{
			# if we're calling this view as a function, store the parameters passed into
			# $core for retrieval
			$core->view = $params;
			include($view);
		}
		else
		{
			core::log('could not find view '.$method);
		}
	}
}

?>