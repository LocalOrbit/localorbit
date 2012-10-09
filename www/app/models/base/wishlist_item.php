<?php
class core_model_base_wishlist_item extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'wishlist_item_id','int',8,'','wishlist_item'));
		$this->add_field(new core_model_field(1,'wishlist_id','int',8,'','wishlist_item'));
		$this->add_field(new core_model_field(2,'product_id','int',8,'','wishlist_item'));
		$this->add_field(new core_model_field(3,'store_id','int',8,'','wishlist_item'));
		$this->add_field(new core_model_field(4,'added_at','timestamp',4,'','wishlist_item'));
		$this->add_field(new core_model_field(5,'description','string',8000,'','wishlist_item'));
		$this->init_data();
	}
}
?>