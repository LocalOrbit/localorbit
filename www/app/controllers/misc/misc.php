<?php 

class core_controller_misc extends core_controller
{
	function __construct($path)
	{
		parent::__construct($path);
		core::ensure_navstate(array('left'=>'left_about'));
	}
}

?>