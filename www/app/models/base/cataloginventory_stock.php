<?php
class core_model_base_cataloginventory_stock extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'stock_id','int',8,'','cataloginventory_stock'));
		$this->add_field(new core_model_field(1,'stock_name','string',-4,'','cataloginventory_stock'));
		$this->init_data();
	}
}
?>