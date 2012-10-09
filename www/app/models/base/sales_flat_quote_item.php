<?php
class core_model_base_sales_flat_quote_item extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'item_id','int',8,'','sales_flat_quote_item'));
		$this->add_field(new core_model_field(1,'quote_id','int',8,'','sales_flat_quote_item'));
		$this->add_field(new core_model_field(2,'created_at','timestamp',4,'','sales_flat_quote_item'));
		$this->add_field(new core_model_field(3,'updated_at','timestamp',4,'','sales_flat_quote_item'));
		$this->add_field(new core_model_field(4,'product_id','int',8,'','sales_flat_quote_item'));
		$this->add_field(new core_model_field(5,'parent_item_id','int',8,'','sales_flat_quote_item'));
		$this->add_field(new core_model_field(6,'is_virtual','int',8,'','sales_flat_quote_item'));
		$this->add_field(new core_model_field(7,'sku','string',-4,'','sales_flat_quote_item'));
		$this->add_field(new core_model_field(8,'name','string',-4,'','sales_flat_quote_item'));
		$this->add_field(new core_model_field(9,'description','string',8000,'','sales_flat_quote_item'));
		$this->add_field(new core_model_field(10,'applied_rule_ids','string',8000,'','sales_flat_quote_item'));
		$this->add_field(new core_model_field(11,'additional_data','string',8000,'','sales_flat_quote_item'));
		$this->add_field(new core_model_field(12,'free_shipping','int',8,'','sales_flat_quote_item'));
		$this->add_field(new core_model_field(13,'is_qty_decimal','int',8,'','sales_flat_quote_item'));
		$this->add_field(new core_model_field(14,'no_discount','int',8,'','sales_flat_quote_item'));
		$this->add_field(new core_model_field(15,'weight','float',10,'2','sales_flat_quote_item'));
		$this->add_field(new core_model_field(16,'qty','float',10,'2','sales_flat_quote_item'));
		$this->add_field(new core_model_field(17,'price','float',10,'2','sales_flat_quote_item'));
		$this->add_field(new core_model_field(18,'base_price','float',10,'2','sales_flat_quote_item'));
		$this->add_field(new core_model_field(19,'custom_price','float',10,'2','sales_flat_quote_item'));
		$this->add_field(new core_model_field(20,'discount_percent','float',10,'2','sales_flat_quote_item'));
		$this->add_field(new core_model_field(21,'discount_amount','float',10,'2','sales_flat_quote_item'));
		$this->add_field(new core_model_field(22,'base_discount_amount','float',10,'2','sales_flat_quote_item'));
		$this->add_field(new core_model_field(23,'tax_percent','float',10,'2','sales_flat_quote_item'));
		$this->add_field(new core_model_field(24,'tax_amount','float',10,'2','sales_flat_quote_item'));
		$this->add_field(new core_model_field(25,'base_tax_amount','float',10,'2','sales_flat_quote_item'));
		$this->add_field(new core_model_field(26,'row_total','float',10,'2','sales_flat_quote_item'));
		$this->add_field(new core_model_field(27,'base_row_total','float',10,'2','sales_flat_quote_item'));
		$this->add_field(new core_model_field(28,'row_total_with_discount','float',10,'2','sales_flat_quote_item'));
		$this->add_field(new core_model_field(29,'row_weight','float',10,'2','sales_flat_quote_item'));
		$this->add_field(new core_model_field(30,'parent_id','string',-4,'','sales_flat_quote_item'));
		$this->add_field(new core_model_field(31,'product_type','string',-4,'','sales_flat_quote_item'));
		$this->add_field(new core_model_field(32,'base_tax_before_discount','float',10,'2','sales_flat_quote_item'));
		$this->add_field(new core_model_field(33,'tax_before_discount','float',10,'2','sales_flat_quote_item'));
		$this->add_field(new core_model_field(34,'original_custom_price','float',10,'2','sales_flat_quote_item'));
		$this->add_field(new core_model_field(35,'gift_message_id','string',-4,'','sales_flat_quote_item'));
		$this->add_field(new core_model_field(36,'weee_tax_applied','string',8000,'','sales_flat_quote_item'));
		$this->add_field(new core_model_field(37,'weee_tax_applied_amount','float',10,'2','sales_flat_quote_item'));
		$this->add_field(new core_model_field(38,'weee_tax_applied_row_amount','float',10,'2','sales_flat_quote_item'));
		$this->add_field(new core_model_field(39,'base_weee_tax_applied_amount','float',10,'2','sales_flat_quote_item'));
		$this->add_field(new core_model_field(40,'base_weee_tax_applied_row_amount','float',10,'2','sales_flat_quote_item'));
		$this->add_field(new core_model_field(41,'weee_tax_disposition','float',10,'2','sales_flat_quote_item'));
		$this->add_field(new core_model_field(42,'weee_tax_row_disposition','float',10,'2','sales_flat_quote_item'));
		$this->add_field(new core_model_field(43,'base_weee_tax_disposition','float',10,'2','sales_flat_quote_item'));
		$this->add_field(new core_model_field(44,'base_weee_tax_row_disposition','float',10,'2','sales_flat_quote_item'));
		$this->add_field(new core_model_field(45,'earned_points_hash','string',8000,'','sales_flat_quote_item'));
		$this->add_field(new core_model_field(46,'redeemed_points_hash','string',8000,'','sales_flat_quote_item'));
		$this->add_field(new core_model_field(47,'row_total_before_redemptions','float',10,'2','sales_flat_quote_item'));
		$this->init_data();
	}
}
?>