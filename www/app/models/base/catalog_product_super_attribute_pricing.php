<?php
class core_model_base_catalog_product_super_attribute_pricing extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'value_id','int',8,'','catalog_product_super_attribute_pricing'));
		$this->add_field(new core_model_field(1,'product_super_attribute_id','int',8,'','catalog_product_super_attribute_pricing'));
		$this->add_field(new core_model_field(2,'value_index','string',-4,'','catalog_product_super_attribute_pricing'));
		$this->add_field(new core_model_field(3,'is_percent','int',8,'','catalog_product_super_attribute_pricing'));
		$this->add_field(new core_model_field(4,'pricing_value','float',10,'2','catalog_product_super_attribute_pricing'));
		$this->add_field(new core_model_field(5,'website_id','int',8,'','catalog_product_super_attribute_pricing'));
		$this->init_data();
	}
}
?>