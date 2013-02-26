<?php
class core_model_base_Product extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'product_id','int',8,'','Product'));
		$this->add_field(new core_model_field(1,'NAME','string',-4,'','Product'));
		$this->add_field(new core_model_field(2,'description','string',8000,'','Product'));
		$this->add_field(new core_model_field(3,'OWNER_ID','int',8,'','Product'));
		$this->add_field(new core_model_field(4,'PICTURE_FILENAME','string',-4,'','Product'));
		$this->add_field(new core_model_field(5,'THUMBNAIL_FILENAME','string',-4,'','Product'));
		$this->add_field(new core_model_field(6,'display','string',-4,'','Product'));
		$this->init_data();
	}
}
?>