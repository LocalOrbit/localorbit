<?php
class core_model_base_catalogrule_product_price extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'rule_product_price_id','int',8,'','catalogrule_product_price'));
		$this->add_field(new core_model_field(1,'rule_date','timestamp',4,'','catalogrule_product_price'));
		$this->add_field(new core_model_field(2,'customer_group_id','int',8,'','catalogrule_product_price'));
		$this->add_field(new core_model_field(3,'product_id','int',8,'','catalogrule_product_price'));
		$this->add_field(new core_model_field(4,'rule_price','float',10,'2','catalogrule_product_price'));
		$this->add_field(new core_model_field(5,'website_id','int',8,'','catalogrule_product_price'));
		$this->add_field(new core_model_field(6,'latest_start_date','timestamp',4,'','catalogrule_product_price'));
		$this->add_field(new core_model_field(7,'earliest_end_date','timestamp',4,'','catalogrule_product_price'));
		$this->add_field(new core_model_field(8,'rules_hash','string',8000,'','catalogrule_product_price'));
		$this->init_data();
	}
}
?>