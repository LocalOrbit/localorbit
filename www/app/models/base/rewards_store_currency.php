<?php
class core_model_base_rewards_store_currency extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'rewards_store_currency_id','int',8,'','rewards_store_currency'));
		$this->add_field(new core_model_field(1,'currency_id','int',8,'','rewards_store_currency'));
		$this->add_field(new core_model_field(2,'store_id','int',8,'','rewards_store_currency'));
		$this->init_data();
	}
}
?>