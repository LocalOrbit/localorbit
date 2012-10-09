<?php
class core_model_base_downloadable_sample_title extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'title_id','int',8,'','downloadable_sample_title'));
		$this->add_field(new core_model_field(1,'sample_id','int',8,'','downloadable_sample_title'));
		$this->add_field(new core_model_field(2,'store_id','int',8,'','downloadable_sample_title'));
		$this->add_field(new core_model_field(3,'title','string',-4,'','downloadable_sample_title'));
		$this->init_data();
	}
}
?>