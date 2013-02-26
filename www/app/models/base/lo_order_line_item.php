<?php
class core_model_base_lo_order_line_item extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'lo_liid','int',8,'','lo_order_line_item'));
		$this->add_field(new core_model_field(1,'lo_oid','int',8,'','lo_order_line_item'));
		$this->add_field(new core_model_field(2,'lo_foid','int',8,'','lo_order_line_item'));
		$this->add_field(new core_model_field(3,'seller_mage_customer_id','int',8,'','lo_order_line_item'));
		$this->add_field(new core_model_field(4,'seller_name','string',-4,'','lo_order_line_item'));
		$this->add_field(new core_model_field(5,'sku','string',-4,'','lo_order_line_item'));
		$this->add_field(new core_model_field(6,'product_name','string',-4,'','lo_order_line_item'));
		$this->add_field(new core_model_field(7,'qty_ordered','int',8,'','lo_order_line_item'));
		$this->add_field(new core_model_field(8,'qty_adjusted','int',8,'','lo_order_line_item'));
		$this->add_field(new core_model_field(9,'qty_delivered','int',8,'','lo_order_line_item'));
		$this->add_field(new core_model_field(10,'unit','string',-4,'','lo_order_line_item'));
		$this->add_field(new core_model_field(11,'unit_price','float',10,'2','lo_order_line_item'));
		$this->add_field(new core_model_field(12,'row_total','float',10,'2','lo_order_line_item'));
		$this->add_field(new core_model_field(13,'unit_plural','string',-4,'','lo_order_line_item'));
		$this->add_field(new core_model_field(14,'row_adjusted_total','float',10,'2','lo_order_line_item'));
		$this->add_field(new core_model_field(15,'adjusted_description','string',8000,'','lo_order_line_item'));
		$this->add_field(new core_model_field(16,'prod_id','int',8,'','lo_order_line_item'));
		$this->add_field(new core_model_field(17,'addr_id','int',8,'','lo_order_line_item'));
		$this->add_field(new core_model_field(18,'dd_id','int',8,'','lo_order_line_item'));
		$this->add_field(new core_model_field(19,'due_time','int',8,'','lo_order_line_item'));
		$this->add_field(new core_model_field(20,'deliv_time','int',8,'','lo_order_line_item'));
		$this->add_field(new core_model_field(21,'seller_org_id','int',8,'','lo_order_line_item'));
		$this->add_field(new core_model_field(22,'lodeliv_id','int',8,'','lo_order_line_item'));
		$this->add_field(new core_model_field(23,'last_status_date','timestamp',4,'','lo_order_line_item'));
		$this->add_field(new core_model_field(24,'lbps_id','int',8,'','lo_order_line_item'));
		$this->add_field(new core_model_field(25,'ldstat_id','int',8,'','lo_order_line_item'));
		$this->add_field(new core_model_field(26,'lsps_id','int',8,'','lo_order_line_item'));
		$this->add_field(new core_model_field(27,'category_ids','string',-4,'','lo_order_line_item'));
		$this->add_field(new core_model_field(28,'final_cat_id','string',-4,'','lo_order_line_item'));
		$this->add_field(new core_model_field(29,'producedat_address_id','int',8,'','lo_order_line_item'));
		$this->add_field(new core_model_field(30,'producedat_org_id','int',8,'','lo_order_line_item'));
		$this->add_field(new core_model_field(31,'producedat_address','string',-4,'','lo_order_line_item'));
		$this->add_field(new core_model_field(32,'producedat_city','string',-4,'','lo_order_line_item'));
		$this->add_field(new core_model_field(33,'producedat_region_id','int',8,'','lo_order_line_item'));
		$this->add_field(new core_model_field(34,'producedat_postal_code','string',-4,'','lo_order_line_item'));
		$this->add_field(new core_model_field(35,'producedat_telephone','string',-4,'','lo_order_line_item'));
		$this->add_field(new core_model_field(36,'producedat_fax','string',-4,'','lo_order_line_item'));
		$this->add_field(new core_model_field(37,'producedat_delivery_instructions','string',8000,'','lo_order_line_item'));
		$this->add_field(new core_model_field(38,'producedat_longitude','string',-4,'','lo_order_line_item'));
		$this->add_field(new core_model_field(39,'producedat_latitude','string',-4,'','lo_order_line_item'));
		$this->init_data();
	}
}
?>