<?php
class core_model_base_phrase_categories extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'pcat_id','int',8,'','phrase_categories'));
		$this->add_field(new core_model_field(1,'name','string',-4,'','phrase_categories'));
		$this->add_field(new core_model_field(2,'sort_order','int',8,'','phrase_categories'));
		$this->init_data();
	}
}
?>