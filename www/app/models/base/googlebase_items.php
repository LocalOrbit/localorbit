<?php
class core_model_base_googlebase_items extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'item_id','int',8,'','googlebase_items'));
		$this->add_field(new core_model_field(1,'type_id','int',8,'','googlebase_items'));
		$this->add_field(new core_model_field(2,'product_id','int',8,'','googlebase_items'));
		$this->add_field(new core_model_field(3,'gbase_item_id','string',-4,'','googlebase_items'));
		$this->add_field(new core_model_field(4,'store_id','int',8,'','googlebase_items'));
		$this->add_field(new core_model_field(5,'published','timestamp',4,'','googlebase_items'));
		$this->add_field(new core_model_field(6,'expires','timestamp',4,'','googlebase_items'));
		$this->add_field(new core_model_field(7,'impr','int',8,'','googlebase_items'));
		$this->add_field(new core_model_field(8,'clicks','int',8,'','googlebase_items'));
		$this->add_field(new core_model_field(9,'views','int',8,'','googlebase_items'));
		$this->add_field(new core_model_field(10,'is_hidden','int',8,'','googlebase_items'));
		$this->init_data();
	}
}
?>