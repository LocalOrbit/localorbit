<?php
class core_model_base_api_assert extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'assert_id','int',8,'','api_assert'));
		$this->add_field(new core_model_field(1,'assert_type','string',-4,'','api_assert'));
		$this->add_field(new core_model_field(2,'assert_data','string',8000,'','api_assert'));
		$this->init_data();
	}
}
?>