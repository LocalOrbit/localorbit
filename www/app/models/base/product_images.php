<?php
class core_model_base_product_images extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'pimg_id','int',8,'','product_images'));
		$this->add_field(new core_model_field(1,'prod_id','int',8,'','product_images'));
		$this->add_field(new core_model_field(2,'extension','string',-4,'','product_images'));
		$this->add_field(new core_model_field(3,'width','int',8,'','product_images'));
		$this->add_field(new core_model_field(4,'height','int',8,'','product_images'));
		$this->add_field(new core_model_field(5,'priority','int',8,'','product_images'));
		$this->add_field(new core_model_field(6,'creation_date','timestamp',4,'','product_images'));
		$this->init_data();
	}
}
?>