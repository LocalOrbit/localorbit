<?php
class core_model_weekly_specials extends core_model_base_weekly_specials
{
	function init_fields()
	{
		global $core;
	
		$this->autojoin(
			'left',
			'domains',
			'(domains.domain_id=weekly_specials.domain_id)',
			array('domains.name as domain_name')
		);
		
		parent::init_fields();
	}
	
	function get_image($spec_id=null)
	{
		global $core;
		if(is_null($spec_id))
		{
			$spec_id = $this['spec_id'];
		}
		
		
		$filepath = $core->paths['base'].'/../img/weeklyspec/'.$spec_id.'.';
		$webpath  = '/img/weeklyspec/'.$spec_id.'.';
		$imgpath = '/img/misc/barn_placeholder_260.png';
		$extension = '';
		if(file_exists($filepath.'png'))	
			$extension = 'png';
		if(file_exists($filepath.'jpg'))	
			$extension = 'jpg';
		if(file_exists($filepath.'gif'))	
			$extension = 'gif';
			
		if($extension == '')
		{
			return array(false,$imgpath,$core->paths['base'].'/..'.$imgpath);
		}
		else
		{
			return array(true,$webpath.$extension,$filepath);
		}
		
	}
}
?>