<?php
class core_model_base_cron_schedule extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'schedule_id','int',8,'','cron_schedule'));
		$this->add_field(new core_model_field(1,'job_code','string',-4,'','cron_schedule'));
		$this->add_field(new core_model_field(2,'status','string',-4,'','cron_schedule'));
		$this->add_field(new core_model_field(3,'messages','string',8000,'','cron_schedule'));
		$this->add_field(new core_model_field(4,'created_at','timestamp',4,'','cron_schedule'));
		$this->add_field(new core_model_field(5,'scheduled_at','timestamp',4,'','cron_schedule'));
		$this->add_field(new core_model_field(6,'executed_at','timestamp',4,'','cron_schedule'));
		$this->add_field(new core_model_field(7,'finished_at','timestamp',4,'','cron_schedule'));
		$this->init_data();
	}
}
?>