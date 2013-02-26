<?php
class core_model_base_rewards_special extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'rewards_special_id','int',8,'','rewards_special'));
		$this->add_field(new core_model_field(1,'name','string',-4,'','rewards_special'));
		$this->add_field(new core_model_field(2,'description','string',8000,'','rewards_special'));
		$this->add_field(new core_model_field(3,'from_date','timestamp',4,'','rewards_special'));
		$this->add_field(new core_model_field(4,'to_date','timestamp',4,'','rewards_special'));
		$this->add_field(new core_model_field(5,'customer_group_ids','string',-4,'','rewards_special'));
		$this->add_field(new core_model_field(6,'is_active','string',8000,'','rewards_special'));
		$this->add_field(new core_model_field(7,'conditions_serialized','string',8000,'','rewards_special'));
		$this->add_field(new core_model_field(8,'points_action','string',-4,'','rewards_special'));
		$this->add_field(new core_model_field(9,'points_currency_id','int',8,'','rewards_special'));
		$this->add_field(new core_model_field(10,'points_amount','int',8,'','rewards_special'));
		$this->add_field(new core_model_field(11,'website_ids','string',8000,'','rewards_special'));
		$this->add_field(new core_model_field(12,'is_rss','int',8,'','rewards_special'));
		$this->add_field(new core_model_field(13,'sort_order','int',8,'','rewards_special'));
		$this->init_data();
	}
}
?>