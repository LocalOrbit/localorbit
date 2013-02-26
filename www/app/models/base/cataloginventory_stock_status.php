<?php
class core_model_base_cataloginventory_stock_status extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'product_id','int',8,'','cataloginventory_stock_status'));
		$this->add_field(new core_model_field(1,'website_id','int',8,'','cataloginventory_stock_status'));
		$this->add_field(new core_model_field(2,'stock_id','int',8,'','cataloginventory_stock_status'));
		$this->add_field(new core_model_field(3,'qty','float',10,'2','cataloginventory_stock_status'));
		$this->add_field(new core_model_field(4,'stock_status','int',8,'','cataloginventory_stock_status'));
		$this->init_data();
	}
}
?>