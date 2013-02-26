<?php
class core_model_newsletter_content extends core_model_base_newsletter_content
{
	function init_fields()
	{
		global $core;
			
		
		$this->autojoin(
			'left',
			'domains',
			'(newsletter_content.domain_id=domains.domain_id)',
			array('domains.name as domain_name')
		);
		parent::init_fields();
	}

	function get_image($cont_id=null)
	{
		global $core;
		if(is_null($cont_id))
		{
			$cont_id = $this['cont_id'];
		}
		
		
		$filepath = $core->paths['base'].'/../img/newsletters/'.$cont_id.'.';
		$webpath  = '/img/newsletters/'.$cont_id.'.';
		$imgpath = '/img/blank.png';
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
			return array(true,$webpath.$extension,$filepath.$extension);
		}
		
	}
}
?>