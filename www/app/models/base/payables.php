<?php
class core_model_base_payables extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'payables_id','int',8,'','payables'));
		$this->add_field(new core_model_field(1,'payables_date','timestamp',4,'','payables'));
		$this->add_field(new core_model_field(2,'from_org_id','int',8,'','payables'));
		$this->add_field(new core_model_field(3,'to_org_id','int',8,'','payables'));
		$this->add_field(new core_model_field(4,'amount','float',10,'2','payables'));
		$this->add_field(new core_model_field(5,'invoice_id','int',8,'','payables'));
		$this->init_data();
	}
}
?>