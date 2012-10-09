<?php
class core_model_base_VendorCatalog extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'CATALOG_ID','int',8,'','VendorCatalog'));
		$this->add_field(new core_model_field(1,'PRODUCT_ID','int',8,'','VendorCatalog'));
		$this->add_field(new core_model_field(2,'VENDOR_ID','int',8,'','VendorCatalog'));
		$this->add_field(new core_model_field(3,'description','string',8000,'','VendorCatalog'));
		$this->add_field(new core_model_field(4,'PICTURE_FILENAME','string',-4,'','VendorCatalog'));
		$this->add_field(new core_model_field(5,'THUMBNAIL_FILENAME','string',-4,'','VendorCatalog'));
		$this->add_field(new core_model_field(6,'HOW','int',8,'','VendorCatalog'));
		$this->add_field(new core_model_field(7,'how_description','string',8000,'','VendorCatalog'));
		$this->init_data();
	}
}
?>