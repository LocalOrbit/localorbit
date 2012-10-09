<?php
class core_model_base_lo_order_delivery_fees extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'lodevfee_id','int',8,'','lo_order_delivery_fees'));
		$this->add_field(new core_model_field(1,'lo_oid','int',8,'','lo_order_delivery_fees'));
		$this->add_field(new core_model_field(2,'devfee_id','int',8,'','lo_order_delivery_fees'));
		$this->add_field(new core_model_field(3,'dd_id','int',8,'','lo_order_delivery_fees'));
		$this->add_field(new core_model_field(4,'fee_type','string',-4,'','lo_order_delivery_fees'));
		$this->add_field(new core_model_field(5,'fee_calc_type_id','int',8,'','lo_order_delivery_fees'));
		$this->add_field(new core_model_field(6,'amount','float',10,'2','lo_order_delivery_fees'));
		$this->add_field(new core_model_field(7,'minimum_order','float',10,'2','lo_order_delivery_fees'));
		$this->add_field(new core_model_field(8,'applied_amount','float',10,'2','lo_order_delivery_fees'));
		$this->init_data();
	}
}
?>