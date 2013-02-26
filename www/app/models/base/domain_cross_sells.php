<?php
class core_model_base_domain_cross_sells extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'dcs_id','int',8,'','domain_cross_sells'));
		$this->add_field(new core_model_field(1,'domain_id','int',8,'','domain_cross_sells'));
		$this->add_field(new core_model_field(2,'accept_from_domain_id','int',8,'','domain_cross_sells'));
		$this->init_data();
	}
}
?>