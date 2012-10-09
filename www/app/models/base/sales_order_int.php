<?php
class core_model_base_sales_order_int extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'value_id','int',8,'','sales_order_int'));
		$this->add_field(new core_model_field(1,'entity_type_id','int',8,'','sales_order_int'));
		$this->add_field(new core_model_field(2,'attribute_id','int',8,'','sales_order_int'));
		$this->add_field(new core_model_field(3,'entity_id','int',8,'','sales_order_int'));
		$this->add_field(new core_model_field(4,'value','int',8,'','sales_order_int'));
		$this->init_data();
	}
}
?>