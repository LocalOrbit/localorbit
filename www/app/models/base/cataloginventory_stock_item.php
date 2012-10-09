<?php
class core_model_base_cataloginventory_stock_item extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'item_id','int',8,'','cataloginventory_stock_item'));
		$this->add_field(new core_model_field(1,'product_id','int',8,'','cataloginventory_stock_item'));
		$this->add_field(new core_model_field(2,'stock_id','int',8,'','cataloginventory_stock_item'));
		$this->add_field(new core_model_field(3,'qty','float',10,'2','cataloginventory_stock_item'));
		$this->add_field(new core_model_field(4,'min_qty','float',10,'2','cataloginventory_stock_item'));
		$this->add_field(new core_model_field(5,'use_config_min_qty','int',8,'','cataloginventory_stock_item'));
		$this->add_field(new core_model_field(6,'is_qty_decimal','int',8,'','cataloginventory_stock_item'));
		$this->add_field(new core_model_field(7,'backorders','int',8,'','cataloginventory_stock_item'));
		$this->add_field(new core_model_field(8,'use_config_backorders','int',8,'','cataloginventory_stock_item'));
		$this->add_field(new core_model_field(9,'min_sale_qty','float',10,'2','cataloginventory_stock_item'));
		$this->add_field(new core_model_field(10,'use_config_min_sale_qty','int',8,'','cataloginventory_stock_item'));
		$this->add_field(new core_model_field(11,'max_sale_qty','float',10,'2','cataloginventory_stock_item'));
		$this->add_field(new core_model_field(12,'use_config_max_sale_qty','int',8,'','cataloginventory_stock_item'));
		$this->add_field(new core_model_field(13,'is_in_stock','int',8,'','cataloginventory_stock_item'));
		$this->add_field(new core_model_field(14,'low_stock_date','timestamp',4,'','cataloginventory_stock_item'));
		$this->add_field(new core_model_field(15,'notify_stock_qty','float',10,'2','cataloginventory_stock_item'));
		$this->add_field(new core_model_field(16,'use_config_notify_stock_qty','int',8,'','cataloginventory_stock_item'));
		$this->add_field(new core_model_field(17,'manage_stock','int',8,'','cataloginventory_stock_item'));
		$this->add_field(new core_model_field(18,'use_config_manage_stock','int',8,'','cataloginventory_stock_item'));
		$this->add_field(new core_model_field(19,'stock_status_changed_automatically','int',8,'','cataloginventory_stock_item'));
		$this->init_data();
	}
}
?>