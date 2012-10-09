<?php
class core_model_base_catalog_product_entity_media_gallery_value extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'value_id','int',8,'','catalog_product_entity_media_gallery_value'));
		$this->add_field(new core_model_field(1,'store_id','int',8,'','catalog_product_entity_media_gallery_value'));
		$this->add_field(new core_model_field(2,'label','string',-4,'','catalog_product_entity_media_gallery_value'));
		$this->add_field(new core_model_field(3,'position','int',8,'','catalog_product_entity_media_gallery_value'));
		$this->add_field(new core_model_field(4,'disabled','int',8,'','catalog_product_entity_media_gallery_value'));
		$this->init_data();
	}
}
?>