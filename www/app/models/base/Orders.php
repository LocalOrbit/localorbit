<?php
class core_model_base_Orders extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'INCREMENT_ID','int',8,'','Orders'));
		$this->add_field(new core_model_field(1,'ORDER_ID','int',8,'','Orders'));
		$this->add_field(new core_model_field(2,'PRODUCT_ID','int',8,'','Orders'));
		$this->add_field(new core_model_field(3,'DATE_ORDERED','int',8,'','Orders'));
		$this->add_field(new core_model_field(4,'ORIG_DEL_DATE','int',8,'','Orders'));
		$this->add_field(new core_model_field(5,'SCHED_DEL_DATE','int',8,'','Orders'));
		$this->add_field(new core_model_field(6,'ACTUAL_DEL_DATE','int',8,'','Orders'));
		$this->add_field(new core_model_field(7,'QUANTITY','int',8,'','Orders'));
		$this->add_field(new core_model_field(8,'UNIT_ID','int',8,'','Orders'));
		$this->add_field(new core_model_field(9,'CENTS_PER_UNIT','int',8,'','Orders'));
		$this->add_field(new core_model_field(10,'VENDOR_ID','int',8,'','Orders'));
		$this->add_field(new core_model_field(11,'CUSTOMER_ID','int',8,'','Orders'));
		$this->add_field(new core_model_field(12,'STATUS_ID','int',8,'','Orders'));
		$this->add_field(new core_model_field(13,'COMMENT','string',8000,'','Orders'));
		$this->add_field(new core_model_field(14,'STOCK_ID','int',8,'','Orders'));
		$this->init_data();
	}
}
?>