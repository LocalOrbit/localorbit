<?php
class core_model_base_directory_currency_rate extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'currency_from','string',-4,'','directory_currency_rate'));
		$this->add_field(new core_model_field(1,'currency_to','string',-4,'','directory_currency_rate'));
		$this->add_field(new core_model_field(2,'rate','float',10,'2','directory_currency_rate'));
		$this->init_data();
	}
}
?>