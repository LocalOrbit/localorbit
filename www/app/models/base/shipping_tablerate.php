<?php
class core_model_base_shipping_tablerate extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'pk','int',8,'','shipping_tablerate'));
		$this->add_field(new core_model_field(1,'website_id','int',8,'','shipping_tablerate'));
		$this->add_field(new core_model_field(2,'dest_country_id','string',-4,'','shipping_tablerate'));
		$this->add_field(new core_model_field(3,'dest_region_id','int',8,'','shipping_tablerate'));
		$this->add_field(new core_model_field(4,'dest_zip','string',-4,'','shipping_tablerate'));
		$this->add_field(new core_model_field(5,'condition_name','string',-4,'','shipping_tablerate'));
		$this->add_field(new core_model_field(6,'condition_value','float',10,'2','shipping_tablerate'));
		$this->add_field(new core_model_field(7,'price','float',10,'2','shipping_tablerate'));
		$this->add_field(new core_model_field(8,'cost','float',10,'2','shipping_tablerate'));
		$this->init_data();
	}
}
?>