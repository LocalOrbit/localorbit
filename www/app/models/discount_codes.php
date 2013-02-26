<?php
class core_model_discount_codes extends core_model_base_discount_codes
{
	function init_fields()
	{
		global $core;
		parent::init_fields();

		$this->autojoin(
			'left',
			'domains',
			'(domains.domain_id=discount_codes.domain_id)',
			array('domains.name as domain_name')
		);

	}
	
	function load_valid_code($code,$org_id=0,$domain_id=0)
	{
		global $core;
		if($org_id == 0) $org_id = $core->session['org_id'];
		if($domain_id == 0) $domain_id = $core->config['domain']['domain_id'];
		
		$sql = '
			select dc.*
			from discount_codes dc
			where dc.code = \''.mysql_escape_string($code).'\'
			and (start_date <= CURRENT_TIMESTAMP or start_date = \'0000-00-00 00:00:00\' or start_date is null)
			and (end_date >= CURRENT_TIMESTAMP or end_date = \'0000-00-00 00:00:00\' or end_date is null)
			and (domain_id = '.$domain_id.' or domain_id =0 or domain_id is null)
			and (restrict_to_buyer_org_id='.$org_id.' or restrict_to_buyer_org_id=0 or restrict_to_buyer_org_id is null)
			and (nbr_uses_global=0 or nbr_uses_global > (select count(disc_use_id) from discount_uses du where du.disc_id=dc.disc_id))
			and (nbr_uses_org=0 or nbr_uses_org > (select count(disc_use_id) from discount_uses du where du.disc_id=dc.disc_id and du.org_id='.$org_id.'))
		';
		
		$this->import(core_db::row($sql));
		return $this;
	}
}
?>