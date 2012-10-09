<?php
class core_model_base_lo_cron_run extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'service_name','string',-4,'','lo_cron_run'));
		$this->add_field(new core_model_field(1,'next_run','timestamp',4,'','lo_cron_run'));
		$this->add_field(new core_model_field(2,'last_run_start','timestamp',4,'','lo_cron_run'));
		$this->add_field(new core_model_field(3,'last_run_end','timestamp',4,'','lo_cron_run'));
		$this->init_data();
	}
}
?>