<?php
class core_model_base_delivery_fees extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'devfee_id','int',8,'','delivery_fees'));
		$this->add_field(new core_model_field(1,'dd_id','int',8,'','delivery_fees'));
		$this->add_field(new core_model_field(2,'fee_type','string',-4,'','delivery_fees'));
		$this->add_field(new core_model_field(3,'fee_calc_type_id','int',8,'','delivery_fees'));
		$this->add_field(new core_model_field(4,'amount','float',10,'2','delivery_fees'));
		$this->add_field(new core_model_field(5,'minimum_order','float',10,'2','delivery_fees'));
		$this->init_data();
	}
}
?>