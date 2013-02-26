<?php
class core_model_base_social_options extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'social_option_id','int',8,'','social_options'));
		$this->add_field(new core_model_field(1,'display_name','string',-4,'','social_options'));
		$this->add_field(new core_model_field(2,'is_disabled','int',8,'','social_options'));
		$this->init_data();
	}
}
?>