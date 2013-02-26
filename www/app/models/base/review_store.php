<?php
class core_model_base_review_store extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'review_id','int',8,'','review_store'));
		$this->add_field(new core_model_field(1,'store_id','int',8,'','review_store'));
		$this->init_data();
	}
}
?>