<?php
class core_model_base_catalog_product_link_attribute_decimal extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'value_id','int',8,'','catalog_product_link_attribute_decimal'));
		$this->add_field(new core_model_field(1,'product_link_attribute_id','int',8,'','catalog_product_link_attribute_decimal'));
		$this->add_field(new core_model_field(2,'link_id','int',8,'','catalog_product_link_attribute_decimal'));
		$this->add_field(new core_model_field(3,'value','float',10,'2','catalog_product_link_attribute_decimal'));
		$this->init_data();
	}
}
?>