<?php
class core_model_base_downloadable_link_purchased extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'purchased_id','int',8,'','downloadable_link_purchased'));
		$this->add_field(new core_model_field(1,'order_id','int',8,'','downloadable_link_purchased'));
		$this->add_field(new core_model_field(2,'order_increment_id','string',-4,'','downloadable_link_purchased'));
		$this->add_field(new core_model_field(3,'order_item_id','int',8,'','downloadable_link_purchased'));
		$this->add_field(new core_model_field(4,'created_at','timestamp',4,'','downloadable_link_purchased'));
		$this->add_field(new core_model_field(5,'updated_at','timestamp',4,'','downloadable_link_purchased'));
		$this->add_field(new core_model_field(6,'customer_id','int',8,'','downloadable_link_purchased'));
		$this->add_field(new core_model_field(7,'product_name','string',-4,'','downloadable_link_purchased'));
		$this->add_field(new core_model_field(8,'product_sku','string',-4,'','downloadable_link_purchased'));
		$this->add_field(new core_model_field(9,'link_section_title','string',-4,'','downloadable_link_purchased'));
		$this->init_data();
	}
}
?>