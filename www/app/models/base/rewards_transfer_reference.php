<?php
class core_model_base_rewards_transfer_reference extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'rewards_transfer_reference_id','int',8,'','rewards_transfer_reference'));
		$this->add_field(new core_model_field(1,'reference_type','int',8,'','rewards_transfer_reference'));
		$this->add_field(new core_model_field(2,'reference_id','int',8,'','rewards_transfer_reference'));
		$this->add_field(new core_model_field(3,'rewards_transfer_id','int',8,'','rewards_transfer_reference'));
		$this->add_field(new core_model_field(4,'rule_id','int',8,'','rewards_transfer_reference'));
		$this->init_data();
	}
}
?>