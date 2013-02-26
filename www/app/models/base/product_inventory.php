<?php
class core_model_base_product_inventory extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'inv_id','int',8,'','product_inventory'));
		$this->add_field(new core_model_field(1,'prod_id','int',8,'','product_inventory'));
		$this->add_field(new core_model_field(2,'lot_id','string',-4,'','product_inventory'));
		$this->add_field(new core_model_field(3,'good_from','timestamp',4,'','product_inventory'));
		$this->add_field(new core_model_field(4,'expires_on','timestamp',4,'','product_inventory'));
		$this->add_field(new core_model_field(5,'qty','float',10,'2','product_inventory'));
		$this->add_field(new core_model_field(6,'creation_date','timestamp',4,'','product_inventory'));
		$this->add_field(new core_model_field(7,'qty_allocated','float',10,'2','product_inventory'));
		$this->init_data();
	}
}
?>