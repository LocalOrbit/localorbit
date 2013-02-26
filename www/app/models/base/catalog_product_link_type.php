<?php
class core_model_base_catalog_product_link_type extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'link_type_id','int',8,'','catalog_product_link_type'));
		$this->add_field(new core_model_field(1,'code','string',-4,'','catalog_product_link_type'));
		$this->init_data();
	}
}
?>