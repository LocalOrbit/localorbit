<?php
class core_model_base_directory_country extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'country_id','string',-4,'','directory_country'));
		$this->add_field(new core_model_field(1,'iso2_code','string',-4,'','directory_country'));
		$this->add_field(new core_model_field(2,'iso3_code','string',-4,'','directory_country'));
		$this->init_data();
	}
}
?>