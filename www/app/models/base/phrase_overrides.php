<?php
class core_model_base_phrase_overrides extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'pover_id','int',8,'','phrase_overrides'));
		$this->add_field(new core_model_field(1,'phrase_id','int',8,'','phrase_overrides'));
		$this->add_field(new core_model_field(2,'domain_id','int',8,'','phrase_overrides'));
		$this->add_field(new core_model_field(3,'lang_id','int',8,'','phrase_overrides'));
		$this->add_field(new core_model_field(4,'override_value','string',-4,'','phrase_overrides'));
		$this->init_data();
	}
}
?>