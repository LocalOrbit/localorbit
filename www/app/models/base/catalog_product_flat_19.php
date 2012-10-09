<?php
class core_model_base_catalog_product_flat_19 extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'entity_id','int',8,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(1,'attribute_set_id','int',8,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(2,'type_id','string',-4,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(3,'short_description','string',8000,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(4,'sku','string',-4,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(5,'weight','float',10,'2','catalog_product_flat_19'));
		$this->add_field(new core_model_field(6,'url_path','string',-4,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(7,'category_ids','string',8000,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(8,'has_options','int',8,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(9,'enable_googlecheckout','int',8,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(10,'links_purchased_separately','int',8,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(11,'links_title','string',-4,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(12,'created_at','timestamp',4,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(13,'updated_at','timestamp',4,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(14,'name','string',-4,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(15,'description','string',8000,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(16,'price','float',10,'2','catalog_product_flat_19'));
		$this->add_field(new core_model_field(17,'special_price','float',10,'2','catalog_product_flat_19'));
		$this->add_field(new core_model_field(18,'special_from_date','timestamp',4,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(19,'special_to_date','timestamp',4,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(20,'small_image','string',-4,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(21,'thumbnail','string',-4,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(22,'news_from_date','timestamp',4,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(23,'news_to_date','timestamp',4,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(24,'tax_class_id','int',8,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(25,'url_key','string',-4,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(26,'required_options','int',8,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(27,'image_label','string',-4,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(28,'small_image_label','string',-4,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(29,'thumbnail_label','string',-4,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(30,'price_type','int',8,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(31,'weight_type','int',8,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(32,'price_view','int',8,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(33,'shipment_type','int',8,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(34,'seller','string',-4,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(35,'producer','string',-4,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(36,'where','string',8000,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(37,'how','string',8000,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(38,'unit_name','string',-4,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(39,'unit_plural','string',-4,'','catalog_product_flat_19'));
		$this->add_field(new core_model_field(40,'display_price_group_0','float',10,'2','catalog_product_flat_19'));
		$this->add_field(new core_model_field(41,'display_price_group_1','float',10,'2','catalog_product_flat_19'));
		$this->add_field(new core_model_field(42,'display_price_group_2','float',10,'2','catalog_product_flat_19'));
		$this->add_field(new core_model_field(43,'display_price_group_3','float',10,'2','catalog_product_flat_19'));
		$this->add_field(new core_model_field(44,'display_price_group_4','float',10,'2','catalog_product_flat_19'));
		$this->add_field(new core_model_field(45,'display_price_group_5','float',10,'2','catalog_product_flat_19'));
		$this->add_field(new core_model_field(46,'display_price_group_6','float',10,'2','catalog_product_flat_19'));
		$this->add_field(new core_model_field(47,'display_price_group_7','float',10,'2','catalog_product_flat_19'));
		$this->add_field(new core_model_field(48,'display_price_group_8','float',10,'2','catalog_product_flat_19'));
		$this->add_field(new core_model_field(49,'display_price_group_9','float',10,'2','catalog_product_flat_19'));
		$this->add_field(new core_model_field(50,'display_price_group_10','float',10,'2','catalog_product_flat_19'));
		$this->init_data();
	}
}
?>