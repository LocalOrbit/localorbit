<?php
class core_model_base_domains_is_live_history extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'dhistlive_id','int',8,'','domains_is_live_history'));
		$this->add_field(new core_model_field(1,'domain_id','int',8,'','domains_is_live_history'));
		$this->add_field(new core_model_field(2,'is_live_start','timestamp',4,'','domains_is_live_history'));
		$this->add_field(new core_model_field(3,'is_live_end','timestamp',4,'','domains_is_live_history'));
		$this->add_field(new core_model_field(4,'is_current','int',8,'','domains_is_live_history'));
		$this->init_data();
	}
}
?>