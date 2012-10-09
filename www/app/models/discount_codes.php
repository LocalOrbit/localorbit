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
}
?>
