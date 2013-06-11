<?php

class core_datacolumn_mike extends core_datacolumn
{
	
	
	
	function render_data($format='html')
	{
		global $core;
		
		#core::log('chekcing format on ');
		
		
		$out = '';
		
		# if there's no template, just output the field's value
		$template_type = 'template_'.$format;
		return $this->$template_type;
	}
	

}

?>