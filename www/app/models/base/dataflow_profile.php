<?php
class core_model_base_dataflow_profile extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'profile_id','int',8,'','dataflow_profile'));
		$this->add_field(new core_model_field(1,'name','string',-4,'','dataflow_profile'));
		$this->add_field(new core_model_field(2,'created_at','timestamp',4,'','dataflow_profile'));
		$this->add_field(new core_model_field(3,'updated_at','timestamp',4,'','dataflow_profile'));
		$this->add_field(new core_model_field(4,'actions_xml','string',8000,'','dataflow_profile'));
		$this->add_field(new core_model_field(5,'gui_data','string',8000,'','dataflow_profile'));
		$this->add_field(new core_model_field(6,'direction','string',-4,'','dataflow_profile'));
		$this->add_field(new core_model_field(7,'entity_type','string',-4,'','dataflow_profile'));
		$this->add_field(new core_model_field(8,'store_id','int',8,'','dataflow_profile'));
		$this->add_field(new core_model_field(9,'data_transfer','int',8,'','dataflow_profile'));
		$this->init_data();
	}
}
?>