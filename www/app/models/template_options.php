<?php
class core_model_template_options extends core_model_base_template_options
{
	function get_options($types=array(),$force_domain=0)
	{
		global $core;
		
		if(is_string($types))
			$types = array($types);
		
		if($force_domain == 0)
			$force_domain = intval($core->config['domain']['domain_id']);
		
		$sql = '
			select t.*,tor.*
			from template_options t
			left join template_option_overrides tor on (t.tempopt_id=tor.tempopt_id and tor.domain_id='.$force_domain.')
		';
		
		if(count($types) > 0)
		{
			$sql .= ' where t.value_type in (\''.implode('\',\'',$types).'\') ';
		}
		
		$opts = array();
		$results = core_db::query($sql);
		while($result = core_db::fetch_assoc($results))
		{
			if($result['override_value'] == 'NULL' || is_null($result['override_value']))
				$opts[$result['name']] = $result['default_value'];
			else
				$opts[$result['name']] = $result['override_value'];
		}
		
		return $opts;
	}
}
?>