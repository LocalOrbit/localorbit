<?php
class core_model_base_invoice_send_dates extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'invoice_send_date_id','int',8,'','invoice_send_dates'));
		$this->add_field(new core_model_field(1,'invoice_id','int',8,'','invoice_send_dates'));
		$this->add_field(new core_model_field(2,'send_date','timestamp',4,'','invoice_send_dates'));
		$this->init_data();
	}
}
?>