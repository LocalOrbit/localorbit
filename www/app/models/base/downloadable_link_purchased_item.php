<?php
class core_model_base_downloadable_link_purchased_item extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'item_id','int',8,'','downloadable_link_purchased_item'));
		$this->add_field(new core_model_field(1,'purchased_id','int',8,'','downloadable_link_purchased_item'));
		$this->add_field(new core_model_field(2,'order_item_id','int',8,'','downloadable_link_purchased_item'));
		$this->add_field(new core_model_field(3,'product_id','int',8,'','downloadable_link_purchased_item'));
		$this->add_field(new core_model_field(4,'link_hash','string',-4,'','downloadable_link_purchased_item'));
		$this->add_field(new core_model_field(5,'number_of_downloads_bought','int',8,'','downloadable_link_purchased_item'));
		$this->add_field(new core_model_field(6,'number_of_downloads_used','int',8,'','downloadable_link_purchased_item'));
		$this->add_field(new core_model_field(7,'link_id','int',8,'','downloadable_link_purchased_item'));
		$this->add_field(new core_model_field(8,'link_title','string',-4,'','downloadable_link_purchased_item'));
		$this->add_field(new core_model_field(9,'is_shareable','int',8,'','downloadable_link_purchased_item'));
		$this->add_field(new core_model_field(10,'link_url','string',-4,'','downloadable_link_purchased_item'));
		$this->add_field(new core_model_field(11,'link_file','string',-4,'','downloadable_link_purchased_item'));
		$this->add_field(new core_model_field(12,'link_type','string',-4,'','downloadable_link_purchased_item'));
		$this->add_field(new core_model_field(13,'status','string',-4,'','downloadable_link_purchased_item'));
		$this->add_field(new core_model_field(14,'created_at','timestamp',4,'','downloadable_link_purchased_item'));
		$this->add_field(new core_model_field(15,'updated_at','timestamp',4,'','downloadable_link_purchased_item'));
		$this->init_data();
	}
}
?>