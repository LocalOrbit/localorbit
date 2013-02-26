<?php
class core_model_base_sales_order_tax extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'tax_id','int',8,'','sales_order_tax'));
		$this->add_field(new core_model_field(1,'order_id','int',8,'','sales_order_tax'));
		$this->add_field(new core_model_field(2,'code','string',-4,'','sales_order_tax'));
		$this->add_field(new core_model_field(3,'title','string',-4,'','sales_order_tax'));
		$this->add_field(new core_model_field(4,'percent','float',10,'2','sales_order_tax'));
		$this->add_field(new core_model_field(5,'amount','float',10,'2','sales_order_tax'));
		$this->add_field(new core_model_field(6,'priority','int',8,'','sales_order_tax'));
		$this->add_field(new core_model_field(7,'position','int',8,'','sales_order_tax'));
		$this->add_field(new core_model_field(8,'base_amount','float',10,'2','sales_order_tax'));
		$this->add_field(new core_model_field(9,'process','int',8,'','sales_order_tax'));
		$this->add_field(new core_model_field(10,'base_real_amount','float',10,'2','sales_order_tax'));
		$this->add_field(new core_model_field(11,'hidden','int',8,'','sales_order_tax'));
		$this->init_data();
	}
}
?>