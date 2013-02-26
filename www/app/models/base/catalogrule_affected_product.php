<?php
class core_model_base_catalogrule_affected_product extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'product_id','int',8,'','catalogrule_affected_product'));
		$this->init_data();
	}
}
?>