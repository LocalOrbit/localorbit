<?php
class core_model_base_lo_order_line_item_inventory extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'loinv_id','int',8,'','lo_order_line_item_inventory'));
		$this->add_field(new core_model_field(1,'lo_liid','int',8,'','lo_order_line_item_inventory'));
		$this->add_field(new core_model_field(2,'inv_id','int',8,'','lo_order_line_item_inventory'));
		$this->add_field(new core_model_field(3,'qty','float',10,'2','lo_order_line_item_inventory'));
		$this->add_field(new core_model_field(4,'qty_delivered','float',10,'2','lo_order_line_item_inventory'));
		$this->init_data();
	}
}
?>