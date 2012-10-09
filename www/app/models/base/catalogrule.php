<?php
class core_model_base_catalogrule extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'rule_id','int',8,'','catalogrule'));
		$this->add_field(new core_model_field(1,'name','string',-4,'','catalogrule'));
		$this->add_field(new core_model_field(2,'description','string',8000,'','catalogrule'));
		$this->add_field(new core_model_field(3,'from_date','timestamp',4,'','catalogrule'));
		$this->add_field(new core_model_field(4,'to_date','timestamp',4,'','catalogrule'));
		$this->add_field(new core_model_field(5,'customer_group_ids','string',-4,'','catalogrule'));
		$this->add_field(new core_model_field(6,'is_active','int',8,'','catalogrule'));
		$this->add_field(new core_model_field(7,'conditions_serialized','string',8000,'','catalogrule'));
		$this->add_field(new core_model_field(8,'actions_serialized','string',8000,'','catalogrule'));
		$this->add_field(new core_model_field(9,'stop_rules_processing','int',8,'','catalogrule'));
		$this->add_field(new core_model_field(10,'sort_order','int',8,'','catalogrule'));
		$this->add_field(new core_model_field(11,'simple_action','string',-4,'','catalogrule'));
		$this->add_field(new core_model_field(12,'discount_amount','float',10,'2','catalogrule'));
		$this->add_field(new core_model_field(13,'website_ids','string',8000,'','catalogrule'));
		$this->add_field(new core_model_field(14,'points_action','string',-4,'','catalogrule'));
		$this->add_field(new core_model_field(15,'points_currency_id','int',8,'','catalogrule'));
		$this->add_field(new core_model_field(16,'points_amount','int',8,'','catalogrule'));
		$this->add_field(new core_model_field(17,'points_amount_step','float',10,'2','catalogrule'));
		$this->add_field(new core_model_field(18,'points_amount_step_currency_id','int',8,'','catalogrule'));
		$this->add_field(new core_model_field(19,'points_max_qty','int',8,'','catalogrule'));
		$this->add_field(new core_model_field(20,'points_catalogrule_simple_action','string',-4,'','catalogrule'));
		$this->add_field(new core_model_field(21,'points_catalogrule_discount_amount','float',10,'2','catalogrule'));
		$this->add_field(new core_model_field(22,'points_catalogrule_stop_rules_processing','int',8,'','catalogrule'));
		$this->add_field(new core_model_field(23,'points_uses_per_product','int',8,'','catalogrule'));
		$this->init_data();
	}
}
?>