<?php
class core_model_base_core_layout_link extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'layout_link_id','int',8,'','core_layout_link'));
		$this->add_field(new core_model_field(1,'store_id','int',8,'','core_layout_link'));
		$this->add_field(new core_model_field(2,'package','string',-4,'','core_layout_link'));
		$this->add_field(new core_model_field(3,'theme','string',-4,'','core_layout_link'));
		$this->add_field(new core_model_field(4,'layout_update_id','int',8,'','core_layout_link'));
		$this->init_data();
	}
}
?>