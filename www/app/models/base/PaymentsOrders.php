<?php
class core_model_base_PaymentsOrders extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'id','int',8,'','PaymentsOrders'));
		$this->add_field(new core_model_field(1,'payments_id','int',8,'','PaymentsOrders'));
		$this->add_field(new core_model_field(2,'ORDER_ID','int',8,'','PaymentsOrders'));
		$this->init_data();
	}
}
?>