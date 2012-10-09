<?php
class core_model_base_directory_country_region_name extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'locale','string',-4,'','directory_country_region_name'));
		$this->add_field(new core_model_field(1,'region_id','int',8,'','directory_country_region_name'));
		$this->add_field(new core_model_field(2,'name','string',-4,'','directory_country_region_name'));
		$this->init_data();
	}
}
?>