<?php
class core_model_base_sales_order extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'entity_id','int',8,'','sales_order'));
		$this->add_field(new core_model_field(1,'entity_type_id','int',8,'','sales_order'));
		$this->add_field(new core_model_field(2,'attribute_set_id','int',8,'','sales_order'));
		$this->add_field(new core_model_field(3,'increment_id','string',-4,'','sales_order'));
		$this->add_field(new core_model_field(4,'parent_id','int',8,'','sales_order'));
		$this->add_field(new core_model_field(5,'store_id','int',8,'','sales_order'));
		$this->add_field(new core_model_field(6,'created_at','timestamp',4,'','sales_order'));
		$this->add_field(new core_model_field(7,'updated_at','timestamp',4,'','sales_order'));
		$this->add_field(new core_model_field(8,'is_active','int',8,'','sales_order'));
		$this->add_field(new core_model_field(9,'customer_id','int',8,'','sales_order'));
		$this->add_field(new core_model_field(10,'tax_amount','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(11,'shipping_amount','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(12,'discount_amount','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(13,'subtotal','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(14,'grand_total','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(15,'total_paid','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(16,'total_refunded','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(17,'total_qty_ordered','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(18,'total_canceled','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(19,'total_invoiced','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(20,'total_online_refunded','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(21,'total_offline_refunded','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(22,'base_tax_amount','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(23,'base_shipping_amount','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(24,'base_discount_amount','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(25,'base_subtotal','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(26,'base_grand_total','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(27,'base_total_paid','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(28,'base_total_refunded','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(29,'base_total_qty_ordered','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(30,'base_total_canceled','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(31,'base_total_invoiced','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(32,'base_total_online_refunded','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(33,'base_total_offline_refunded','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(34,'subtotal_refunded','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(35,'subtotal_canceled','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(36,'discount_refunded','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(37,'discount_canceled','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(38,'discount_invoiced','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(39,'tax_refunded','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(40,'tax_canceled','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(41,'shipping_refunded','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(42,'shipping_canceled','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(43,'base_subtotal_refunded','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(44,'base_subtotal_canceled','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(45,'base_discount_refunded','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(46,'base_discount_canceled','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(47,'base_discount_invoiced','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(48,'base_tax_refunded','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(49,'base_tax_canceled','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(50,'base_shipping_refunded','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(51,'base_shipping_canceled','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(52,'subtotal_invoiced','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(53,'tax_invoiced','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(54,'shipping_invoiced','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(55,'base_subtotal_invoiced','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(56,'base_tax_invoiced','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(57,'base_shipping_invoiced','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(58,'shipping_tax_amount','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(59,'base_shipping_tax_amount','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(60,'shipping_tax_refunded','float',10,'2','sales_order'));
		$this->add_field(new core_model_field(61,'base_shipping_tax_refunded','float',10,'2','sales_order'));
		$this->init_data();
	}
}
?>