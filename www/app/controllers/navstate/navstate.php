<?php

class core_controller_navstate extends core_controller
{
	function ensure()
	{
		global $core;
		core::log('nav state: '.print_r($core->config['navstate'],true));
		foreach($core->config['navstate'] as $position=>$view)
		{
			if($core->config['current_navstate'][$position] != $view)
			{
				core::log('attempting to ensure '.$view);
				$this->$view();
				$core->config['current_navstate'][$position] = $view;
			}
		}
		
		if($core->config['current_navstate']['nav1'] != 'authed' && $core->session['user_id'] > 0)
		{
			$this->nav1_authed();
		}
		else if(
			$core->config['current_navstate']['nav1'] != 'unauthed' &&
			$core->session['user_id'] == 0 &&
			$core->config['domain']['feature_allow_anonymous_shopping'] != 1
		)
		{
			$this->nav1_unauthed();
		}
		else
		{
			$this->nav1_unauthed_anon();
		}
		
	}
}

?>