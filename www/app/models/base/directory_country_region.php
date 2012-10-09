<?php
class core_model_base_directory_country_region extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'region_id','int',8,'','directory_country_region'));
		$this->add_field(new core_model_field(1,'country_id','string',-4,'','directory_country_region'));
		$this->add_field(new core_model_field(2,'code','string',-4,'','directory_country_region'));
		$this->add_field(new core_model_field(3,'default_name','string',-4,'','directory_country_region'));
		$this->init_data();
	}
}
?>