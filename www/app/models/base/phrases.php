<?php
class core_model_base_phrases extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'phrase_id','int',8,'','phrases'));
		$this->add_field(new core_model_field(1,'pcat_id','int',8,'','phrases'));
		$this->add_field(new core_model_field(2,'label','string',-4,'','phrases'));
		$this->add_field(new core_model_field(3,'tags','string',-4,'','phrases'));
		$this->add_field(new core_model_field(4,'default_value','string',8000,'','phrases'));
		$this->add_field(new core_model_field(5,'sort_order','int',8,'','phrases'));
		$this->add_field(new core_model_field(6,'edit_type','string',8000,'','phrases'));
		$this->add_field(new core_model_field(7,'info_note','string',8000,'','phrases'));
		$this->init_data();
	}
}
?>