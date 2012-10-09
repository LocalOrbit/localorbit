<?php
class core_model_base_core_layout_update extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'layout_update_id','int',8,'','core_layout_update'));
		$this->add_field(new core_model_field(1,'handle','string',-4,'','core_layout_update'));
		$this->add_field(new core_model_field(2,'xml','string',8000,'','core_layout_update'));
		$this->init_data();
	}
}
?>