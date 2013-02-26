<?php
class core_model_base_Inventory extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'STOCK_ID','int',8,'','Inventory'));
		$this->add_field(new core_model_field(1,'PRODUCT_ID','int',8,'','Inventory'));
		$this->add_field(new core_model_field(2,'START_DATE','timestamp',4,'','Inventory'));
		$this->add_field(new core_model_field(3,'START_QUANTITY','int',8,'','Inventory'));
		$this->add_field(new core_model_field(4,'CURRENT_QUANTITY','int',8,'','Inventory'));
		$this->add_field(new core_model_field(5,'UNIT_ID','int',8,'','Inventory'));
		$this->add_field(new core_model_field(6,'CENTS_PER_UNIT','int',8,'','Inventory'));
		$this->add_field(new core_model_field(7,'VENDOR_ID','int',8,'','Inventory'));
		$this->add_field(new core_model_field(8,'DISCOUNT_PERCENT','int',8,'','Inventory'));
		$this->add_field(new core_model_field(9,'DISCOUNT_DAY','int',8,'','Inventory'));
		$this->add_field(new core_model_field(10,'WHOLESALE_PRICE','int',8,'','Inventory'));
		$this->add_field(new core_model_field(11,'MINIMUM_QUANTITY','int',8,'','Inventory'));
		$this->add_field(new core_model_field(12,'SELL_BY_DATE','string',-4,'','Inventory'));
		$this->init_data();
	}
}
?>