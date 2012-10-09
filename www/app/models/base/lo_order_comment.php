<?php
class core_model_base_lo_order_comment extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'lo_ocid','int',8,'','lo_order_comment'));
		$this->add_field(new core_model_field(1,'lo_order_id','int',8,'','lo_order_comment'));
		$this->add_field(new core_model_field(2,'lo_fulfilment_order_id','int',8,'','lo_order_comment'));
		$this->add_field(new core_model_field(3,'comment','string',8000,'','lo_order_comment'));
		$this->init_data();
	}
}
?>