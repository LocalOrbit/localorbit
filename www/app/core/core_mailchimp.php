<?

class core_mailchimp
{
	function __construct($key=null)
	{
		global $core;
		if(is_null($key))
		{
			$key = $core->config['mailchimp']['key'];
		}
		$this->key = $key;
		core::log('mailchimp init using key '.$this->key);
		$this->api =new MCAPI($this->key);
	}
	
	function get_list_id($name)
	{
		$lists = $this->api->lists();
		foreach($lists['data'] as $list)
		{
			#echo($cam['title'].'<br />');sen
			if($list['name'] == $name)
			{
				return $list['id'];
			}
		}
		return 0;
	}
	
	function get_campaign_id($title)
	{
		global $api;
		$cams = $this->api->campaigns();
		foreach($cams['data'] as $cam)
		{
			#echo($cam['title'].'<br />');
			if($cam['title'] == $title)
			{
				return $cam['id'];
			}
		}
		return 0;
	}

	function get_template_id($name,$domain_id=null)
	{
		global $api,$core;

		$name = str_replace(' ','',strtolower($name));
		$generic_id = 0;
		if(is_null($domain_id))
			$domain_id = $core->config['domain']['domain_id'];
		
		$templates = $this->api->templates();
		core::log('looking mc template '.$name.'-'.$domain_id);
		foreach($templates as $user_template)
		{
			foreach($user_template as $template)
			{
				# if we find a template that is domain specific, return that immediately
				$template_name = str_replace(' ','',strtolower($template['name']));
				if($template_name == $name.'-'.$domain_id)
				{
					return $template['id'];
				}
				# if we find a general template, store the id in case we don't find a domain-specific one
				if($template_name == $name)
				{
					$generic_id = $template['id'];
				}
			}
		}
		
		# return the generic template, or zero
		return $generic_id;
	}
	
	function __call($method,$p)
	{
		return $this->api->$method($p[0],$p[1],$p[2],$p[3],$p[4],$p[5]);
	}
}