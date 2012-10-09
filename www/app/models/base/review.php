<?php
class core_model_base_review extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'review_id','int',8,'','review'));
		$this->add_field(new core_model_field(1,'created_at','timestamp',4,'','review'));
		$this->add_field(new core_model_field(2,'entity_id','int',8,'','review'));
		$this->add_field(new core_model_field(3,'entity_pk_value','int',8,'','review'));
		$this->add_field(new core_model_field(4,'status_id','int',8,'','review'));
		$this->init_data();
	}
}
?>