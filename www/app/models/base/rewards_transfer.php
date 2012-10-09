<?php
class core_model_base_rewards_transfer extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'rewards_transfer_id','int',8,'','rewards_transfer'));
		$this->add_field(new core_model_field(1,'customer_id','int',8,'','rewards_transfer'));
		$this->add_field(new core_model_field(2,'quantity','int',8,'','rewards_transfer'));
		$this->add_field(new core_model_field(3,'comments','string',-4,'','rewards_transfer'));
		$this->add_field(new core_model_field(4,'effective_start','timestamp',4,'','rewards_transfer'));
		$this->add_field(new core_model_field(5,'expire_date','timestamp',4,'','rewards_transfer'));
		$this->add_field(new core_model_field(6,'status','int',8,'','rewards_transfer'));
		$this->add_field(new core_model_field(7,'currency_id','int',8,'','rewards_transfer'));
		$this->add_field(new core_model_field(8,'creation_ts','timestamp',4,'','rewards_transfer'));
		$this->add_field(new core_model_field(9,'reason_id','int',8,'','rewards_transfer'));
		$this->add_field(new core_model_field(10,'last_update_ts','timestamp',4,'','rewards_transfer'));
		$this->add_field(new core_model_field(11,'issued_by','string',-4,'','rewards_transfer'));
		$this->add_field(new core_model_field(12,'last_update_by','string',-4,'','rewards_transfer'));
		$this->init_data();
	}
}
?>