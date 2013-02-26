<?php
class core_model_base_sales_flat_order_item extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'item_id','int',8,'','sales_flat_order_item'));
		$this->add_field(new core_model_field(1,'order_id','int',8,'','sales_flat_order_item'));
		$this->add_field(new core_model_field(2,'parent_item_id','int',8,'','sales_flat_order_item'));
		$this->add_field(new core_model_field(3,'quote_item_id','int',8,'','sales_flat_order_item'));
		$this->add_field(new core_model_field(4,'created_at','timestamp',4,'','sales_flat_order_item'));
		$this->add_field(new core_model_field(5,'updated_at','timestamp',4,'','sales_flat_order_item'));
		$this->add_field(new core_model_field(6,'product_id','int',8,'','sales_flat_order_item'));
		$this->add_field(new core_model_field(7,'product_type','string',-4,'','sales_flat_order_item'));
		$this->add_field(new core_model_field(8,'product_options','string',8000,'','sales_flat_order_item'));
		$this->add_field(new core_model_field(9,'weight','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(10,'is_virtual','int',8,'','sales_flat_order_item'));
		$this->add_field(new core_model_field(11,'sku','string',-4,'','sales_flat_order_item'));
		$this->add_field(new core_model_field(12,'name','string',-4,'','sales_flat_order_item'));
		$this->add_field(new core_model_field(13,'description','string',8000,'','sales_flat_order_item'));
		$this->add_field(new core_model_field(14,'applied_rule_ids','string',8000,'','sales_flat_order_item'));
		$this->add_field(new core_model_field(15,'additional_data','string',8000,'','sales_flat_order_item'));
		$this->add_field(new core_model_field(16,'free_shipping','int',8,'','sales_flat_order_item'));
		$this->add_field(new core_model_field(17,'is_qty_decimal','int',8,'','sales_flat_order_item'));
		$this->add_field(new core_model_field(18,'no_discount','int',8,'','sales_flat_order_item'));
		$this->add_field(new core_model_field(19,'qty_backordered','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(20,'qty_canceled','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(21,'qty_invoiced','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(22,'qty_ordered','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(23,'qty_refunded','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(24,'qty_shipped','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(25,'cost','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(26,'price','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(27,'base_price','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(28,'original_price','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(29,'base_original_price','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(30,'tax_percent','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(31,'tax_amount','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(32,'base_tax_amount','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(33,'tax_invoiced','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(34,'base_tax_invoiced','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(35,'discount_percent','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(36,'discount_amount','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(37,'base_discount_amount','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(38,'discount_invoiced','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(39,'base_discount_invoiced','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(40,'amount_refunded','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(41,'base_amount_refunded','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(42,'row_total','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(43,'base_row_total','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(44,'row_invoiced','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(45,'base_row_invoiced','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(46,'row_weight','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(47,'gift_message_id','int',8,'','sales_flat_order_item'));
		$this->add_field(new core_model_field(48,'gift_message_available','int',8,'','sales_flat_order_item'));
		$this->add_field(new core_model_field(49,'base_tax_before_discount','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(50,'tax_before_discount','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(51,'weee_tax_applied','string',8000,'','sales_flat_order_item'));
		$this->add_field(new core_model_field(52,'weee_tax_applied_amount','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(53,'weee_tax_applied_row_amount','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(54,'base_weee_tax_applied_amount','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(55,'base_weee_tax_applied_row_amount','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(56,'weee_tax_disposition','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(57,'weee_tax_row_disposition','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(58,'base_weee_tax_disposition','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(59,'base_weee_tax_row_disposition','float',10,'2','sales_flat_order_item'));
		$this->add_field(new core_model_field(60,'ext_order_item_id','string',-4,'','sales_flat_order_item'));
		$this->add_field(new core_model_field(61,'locked_do_invoice','int',8,'','sales_flat_order_item'));
		$this->add_field(new core_model_field(62,'locked_do_ship','int',8,'','sales_flat_order_item'));
		$this->init_data();
	}
}
?>