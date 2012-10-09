<?php
class core_model_base_catalog_product_entity_media_gallery extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'value_id','int',8,'','catalog_product_entity_media_gallery'));
		$this->add_field(new core_model_field(1,'attribute_id','int',8,'','catalog_product_entity_media_gallery'));
		$this->add_field(new core_model_field(2,'entity_id','int',8,'','catalog_product_entity_media_gallery'));
		$this->add_field(new core_model_field(3,'value','string',-4,'','catalog_product_entity_media_gallery'));
		$this->init_data();
	}
}
?>