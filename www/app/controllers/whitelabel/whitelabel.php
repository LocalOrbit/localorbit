<?php 

class core_controller_whitelabel extends core_controller
{
	function get_options()
	{
		global $core;
		
	
		core::log('whitelable controller called for '.$core->config['domain']['name']);
		$logo =image('logo-large');
		
		# these are the defaults:
		if($core->config['domain']['custom_tagline'] == '')
		{
			core::replace('tagline','re-linking the food chain &trade;');
		}
		else
		{
			core::replace('tagline',$core->config['domain']['custom_tagline']);
		}
		core::replace('logo','<img src="'.$logo.'?__time='.time().'" />');
		core::replace('footer_logo','<img src="'.image('logo-small').'?__time='.time().'" />');
		
		if(strpos($logo,'app/../img/default/') === false)
		{
			#core::replace('poweredby','<img src="/img/misc/poweredby_lo.png" />');
		}
		
		# this draws all the footer links
		if($core->data['public'] == 'yes')
			$this->public_footer();
		else
			$this->handle_footer();
	}
}

?>