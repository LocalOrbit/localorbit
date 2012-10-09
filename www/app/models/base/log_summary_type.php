<?php
class core_model_base_log_summary_type extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'type_id','int',8,'','log_summary_type'));
		$this->add_field(new core_model_field(1,'type_code','string',-4,'','log_summary_type'));
		$this->add_field(new core_model_field(2,'period','int',8,'','log_summary_type'));
		$this->add_field(new core_model_field(3,'period_type','string',-4,'','log_summary_type'));
		$this->init_data();
	}
}
?>