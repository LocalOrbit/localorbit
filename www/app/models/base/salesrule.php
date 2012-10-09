<?php
class core_model_base_salesrule extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'rule_id','int',8,'','salesrule'));
		$this->add_field(new core_model_field(1,'name','string',-4,'','salesrule'));
		$this->add_field(new core_model_field(2,'description','string',8000,'','salesrule'));
		$this->add_field(new core_model_field(3,'from_date','timestamp',4,'','salesrule'));
		$this->add_field(new core_model_field(4,'to_date','timestamp',4,'','salesrule'));
		$this->add_field(new core_model_field(5,'coupon_code','string',-4,'','salesrule'));
		$this->add_field(new core_model_field(6,'uses_per_coupon','int',8,'','salesrule'));
		$this->add_field(new core_model_field(7,'uses_per_customer','int',8,'','salesrule'));
		$this->add_field(new core_model_field(8,'customer_group_ids','string',-4,'','salesrule'));
		$this->add_field(new core_model_field(9,'is_active','int',8,'','salesrule'));
		$this->add_field(new core_model_field(10,'conditions_serialized','string',8000,'','salesrule'));
		$this->add_field(new core_model_field(11,'actions_serialized','string',8000,'','salesrule'));
		$this->add_field(new core_model_field(12,'stop_rules_processing','int',8,'','salesrule'));
		$this->add_field(new core_model_field(13,'is_advanced','int',8,'','salesrule'));
		$this->add_field(new core_model_field(14,'product_ids','string',8000,'','salesrule'));
		$this->add_field(new core_model_field(15,'sort_order','int',8,'','salesrule'));
		$this->add_field(new core_model_field(16,'simple_action','string',-4,'','salesrule'));
		$this->add_field(new core_model_field(17,'discount_amount','float',10,'2','salesrule'));
		$this->add_field(new core_model_field(18,'discount_qty','float',10,'2','salesrule'));
		$this->add_field(new core_model_field(19,'discount_step','int',8,'','salesrule'));
		$this->add_field(new core_model_field(20,'simple_free_shipping','int',8,'','salesrule'));
		$this->add_field(new core_model_field(21,'times_used','int',8,'','salesrule'));
		$this->add_field(new core_model_field(22,'is_rss','int',8,'','salesrule'));
		$this->add_field(new core_model_field(23,'website_ids','string',8000,'','salesrule'));
		$this->add_field(new core_model_field(24,'points_action','string',-4,'','salesrule'));
		$this->add_field(new core_model_field(25,'points_currency_id','int',8,'','salesrule'));
		$this->add_field(new core_model_field(26,'points_amount','int',8,'','salesrule'));
		$this->add_field(new core_model_field(27,'points_amount_step','float',10,'2','salesrule'));
		$this->add_field(new core_model_field(28,'points_amount_step_currency_id','int',8,'','salesrule'));
		$this->add_field(new core_model_field(29,'points_qty_step','int',8,'','salesrule'));
		$this->add_field(new core_model_field(30,'points_max_qty','int',8,'','salesrule'));
		$this->init_data();
	}
}
?>