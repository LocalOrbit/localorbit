<?php
class core_model_base_directory_country_format extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'country_format_id','int',8,'','directory_country_format'));
		$this->add_field(new core_model_field(1,'country_id','string',-4,'','directory_country_format'));
		$this->add_field(new core_model_field(2,'type','string',-4,'','directory_country_format'));
		$this->add_field(new core_model_field(3,'format','string',8000,'','directory_country_format'));
		$this->init_data();
	}
}
?>