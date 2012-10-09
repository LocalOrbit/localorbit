<?php
class core_model_base_lo_seller_payment_statuses extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'lsps_id','int',8,'','lo_seller_payment_statuses'));
		$this->add_field(new core_model_field(1,'seller_payment_status','string',-4,'','lo_seller_payment_statuses'));
		$this->init_data();
	}
}
?>