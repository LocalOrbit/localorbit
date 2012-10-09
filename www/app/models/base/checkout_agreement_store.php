<?php
class core_model_base_checkout_agreement_store extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'agreement_id','int',8,'','checkout_agreement_store'));
		$this->add_field(new core_model_field(1,'store_id','int',8,'','checkout_agreement_store'));
		$this->init_data();
	}
}
?>