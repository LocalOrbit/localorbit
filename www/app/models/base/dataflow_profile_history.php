<?php
class core_model_base_dataflow_profile_history extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'history_id','int',8,'','dataflow_profile_history'));
		$this->add_field(new core_model_field(1,'profile_id','int',8,'','dataflow_profile_history'));
		$this->add_field(new core_model_field(2,'action_code','string',-4,'','dataflow_profile_history'));
		$this->add_field(new core_model_field(3,'user_id','int',8,'','dataflow_profile_history'));
		$this->add_field(new core_model_field(4,'performed_at','timestamp',4,'','dataflow_profile_history'));
		$this->init_data();
	}
}
?>