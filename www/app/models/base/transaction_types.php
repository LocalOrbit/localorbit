<?php
class core_model_base_transaction_types extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'ttype_id','int',8,'','transaction_types'));
		$this->add_field(new core_model_field(1,'name','string',-4,'','transaction_types'));
		$this->init_data();
	}
}
?>