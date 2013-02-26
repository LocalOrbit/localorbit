<?php
class core_model_base_tag_relation extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'tag_relation_id','int',8,'','tag_relation'));
		$this->add_field(new core_model_field(1,'tag_id','int',8,'','tag_relation'));
		$this->add_field(new core_model_field(2,'customer_id','int',8,'','tag_relation'));
		$this->add_field(new core_model_field(3,'product_id','int',8,'','tag_relation'));
		$this->add_field(new core_model_field(4,'store_id','int',8,'','tag_relation'));
		$this->add_field(new core_model_field(5,'active','int',8,'','tag_relation'));
		$this->add_field(new core_model_field(6,'created_at','timestamp',4,'','tag_relation'));
		$this->init_data();
	}
}
?>