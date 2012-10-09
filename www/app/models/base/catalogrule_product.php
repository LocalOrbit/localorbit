<?php
class core_model_base_catalogrule_product extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'rule_product_id','int',8,'','catalogrule_product'));
		$this->add_field(new core_model_field(1,'rule_id','int',8,'','catalogrule_product'));
		$this->add_field(new core_model_field(2,'from_time','int',8,'','catalogrule_product'));
		$this->add_field(new core_model_field(3,'to_time','int',8,'','catalogrule_product'));
		$this->add_field(new core_model_field(4,'customer_group_id','int',8,'','catalogrule_product'));
		$this->add_field(new core_model_field(5,'product_id','int',8,'','catalogrule_product'));
		$this->add_field(new core_model_field(6,'action_operator','string',-4,'','catalogrule_product'));
		$this->add_field(new core_model_field(7,'action_amount','float',10,'2','catalogrule_product'));
		$this->add_field(new core_model_field(8,'action_stop','int',8,'','catalogrule_product'));
		$this->add_field(new core_model_field(9,'sort_order','int',8,'','catalogrule_product'));
		$this->add_field(new core_model_field(10,'website_id','int',8,'','catalogrule_product'));
		$this->init_data();
	}
}
?>