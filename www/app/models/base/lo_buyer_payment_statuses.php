<?php
class core_model_base_lo_buyer_payment_statuses extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'lbps_id','int',8,'','lo_buyer_payment_statuses'));
		$this->add_field(new core_model_field(1,'buyer_payment_status','string',-4,'','lo_buyer_payment_statuses'));
		$this->init_data();
	}
}
?>