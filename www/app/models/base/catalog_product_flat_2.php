<?php
class core_model_base_catalog_product_flat_2 extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'entity_id','int',8,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(1,'attribute_set_id','int',8,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(2,'type_id','string',-4,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(3,'category_ids','string',8000,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(4,'created_at','timestamp',4,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(5,'description','string',8000,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(6,'enable_googlecheckout','int',8,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(7,'has_options','int',8,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(8,'how','string',8000,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(9,'image_label','string',-4,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(10,'links_purchased_separately','int',8,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(11,'links_title','string',-4,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(12,'name','string',-4,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(13,'news_from_date','timestamp',4,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(14,'news_to_date','timestamp',4,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(15,'price','float',10,'2','catalog_product_flat_2'));
		$this->add_field(new core_model_field(16,'price_type','int',8,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(17,'price_view','int',8,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(18,'producer','string',-4,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(19,'where','string',8000,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(20,'required_options','int',8,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(21,'seller','string',-4,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(22,'shipment_type','int',8,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(23,'short_description','string',8000,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(24,'sku','string',-4,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(25,'small_image','string',-4,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(26,'small_image_label','string',-4,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(27,'special_from_date','timestamp',4,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(28,'special_price','float',10,'2','catalog_product_flat_2'));
		$this->add_field(new core_model_field(29,'special_to_date','timestamp',4,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(30,'tax_class_id','int',8,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(31,'thumbnail','string',-4,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(32,'thumbnail_label','string',-4,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(33,'unit_name','string',-4,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(34,'unit_plural','string',-4,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(35,'updated_at','timestamp',4,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(36,'url_key','string',-4,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(37,'url_path','string',-4,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(38,'weight','float',10,'2','catalog_product_flat_2'));
		$this->add_field(new core_model_field(39,'weight_type','int',8,'','catalog_product_flat_2'));
		$this->add_field(new core_model_field(40,'display_price_group_0','float',10,'2','catalog_product_flat_2'));
		$this->add_field(new core_model_field(41,'display_price_group_1','float',10,'2','catalog_product_flat_2'));
		$this->add_field(new core_model_field(42,'display_price_group_2','float',10,'2','catalog_product_flat_2'));
		$this->add_field(new core_model_field(43,'display_price_group_3','float',10,'2','catalog_product_flat_2'));
		$this->add_field(new core_model_field(44,'display_price_group_4','float',10,'2','catalog_product_flat_2'));
		$this->add_field(new core_model_field(45,'display_price_group_5','float',10,'2','catalog_product_flat_2'));
		$this->add_field(new core_model_field(46,'display_price_group_6','float',10,'2','catalog_product_flat_2'));
		$this->add_field(new core_model_field(47,'display_price_group_7','float',10,'2','catalog_product_flat_2'));
		$this->add_field(new core_model_field(48,'display_price_group_8','float',10,'2','catalog_product_flat_2'));
		$this->add_field(new core_model_field(49,'display_price_group_9','float',10,'2','catalog_product_flat_2'));
		$this->add_field(new core_model_field(50,'display_price_group_10','float',10,'2','catalog_product_flat_2'));
		$this->init_data();
	}
}
?>