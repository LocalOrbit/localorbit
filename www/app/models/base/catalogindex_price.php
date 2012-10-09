<?php
class core_model_base_catalogindex_price extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'entity_id','int',8,'','catalogindex_price'));
		$this->add_field(new core_model_field(1,'attribute_id','int',8,'','catalogindex_price'));
		$this->add_field(new core_model_field(2,'customer_group_id','int',8,'','catalogindex_price'));
		$this->add_field(new core_model_field(3,'qty','float',10,'2','catalogindex_price'));
		$this->add_field(new core_model_field(4,'value','float',10,'2','catalogindex_price'));
		$this->add_field(new core_model_field(5,'tax_class_id','int',8,'','catalogindex_price'));
		$this->add_field(new core_model_field(6,'website_id','int',8,'','catalogindex_price'));
		$this->init_data();
	}
}
?>