<?php
class core_model_base_rewards_customer extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'rewards_customer_id','int',8,'','rewards_customer'));
		$this->add_field(new core_model_field(1,'rewards_currency_id','int',8,'','rewards_customer'));
		$this->add_field(new core_model_field(2,'customer_entity_id','int',8,'','rewards_customer'));
		$this->init_data();
	}
}
?>