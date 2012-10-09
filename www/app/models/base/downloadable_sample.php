<?php
class core_model_base_downloadable_sample extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'sample_id','int',8,'','downloadable_sample'));
		$this->add_field(new core_model_field(1,'product_id','int',8,'','downloadable_sample'));
		$this->add_field(new core_model_field(2,'sample_url','string',-4,'','downloadable_sample'));
		$this->add_field(new core_model_field(3,'sample_file','string',-4,'','downloadable_sample'));
		$this->add_field(new core_model_field(4,'sample_type','string',-4,'','downloadable_sample'));
		$this->add_field(new core_model_field(5,'sort_order','int',8,'','downloadable_sample'));
		$this->init_data();
	}
}
?>