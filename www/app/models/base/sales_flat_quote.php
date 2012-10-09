<?php
class core_model_base_sales_flat_quote extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'entity_id','int',8,'','sales_flat_quote'));
		$this->add_field(new core_model_field(1,'store_id','int',8,'','sales_flat_quote'));
		$this->add_field(new core_model_field(2,'created_at','timestamp',4,'','sales_flat_quote'));
		$this->add_field(new core_model_field(3,'updated_at','timestamp',4,'','sales_flat_quote'));
		$this->add_field(new core_model_field(4,'converted_at','timestamp',4,'','sales_flat_quote'));
		$this->add_field(new core_model_field(5,'is_active','int',8,'','sales_flat_quote'));
		$this->add_field(new core_model_field(6,'is_virtual','int',8,'','sales_flat_quote'));
		$this->add_field(new core_model_field(7,'is_multi_shipping','int',8,'','sales_flat_quote'));
		$this->add_field(new core_model_field(8,'items_count','int',8,'','sales_flat_quote'));
		$this->add_field(new core_model_field(9,'items_qty','float',10,'2','sales_flat_quote'));
		$this->add_field(new core_model_field(10,'orig_order_id','int',8,'','sales_flat_quote'));
		$this->add_field(new core_model_field(11,'store_to_base_rate','float',10,'2','sales_flat_quote'));
		$this->add_field(new core_model_field(12,'store_to_quote_rate','float',10,'2','sales_flat_quote'));
		$this->add_field(new core_model_field(13,'base_currency_code','string',-4,'','sales_flat_quote'));
		$this->add_field(new core_model_field(14,'store_currency_code','string',-4,'','sales_flat_quote'));
		$this->add_field(new core_model_field(15,'quote_currency_code','string',-4,'','sales_flat_quote'));
		$this->add_field(new core_model_field(16,'grand_total','float',10,'2','sales_flat_quote'));
		$this->add_field(new core_model_field(17,'base_grand_total','float',10,'2','sales_flat_quote'));
		$this->add_field(new core_model_field(18,'checkout_method','string',-4,'','sales_flat_quote'));
		$this->add_field(new core_model_field(19,'customer_id','int',8,'','sales_flat_quote'));
		$this->add_field(new core_model_field(20,'customer_tax_class_id','int',8,'','sales_flat_quote'));
		$this->add_field(new core_model_field(21,'customer_group_id','int',8,'','sales_flat_quote'));
		$this->add_field(new core_model_field(22,'customer_email','string',-4,'','sales_flat_quote'));
		$this->add_field(new core_model_field(23,'customer_prefix','string',-4,'','sales_flat_quote'));
		$this->add_field(new core_model_field(24,'customer_firstname','string',-4,'','sales_flat_quote'));
		$this->add_field(new core_model_field(25,'customer_middlename','string',-4,'','sales_flat_quote'));
		$this->add_field(new core_model_field(26,'customer_lastname','string',-4,'','sales_flat_quote'));
		$this->add_field(new core_model_field(27,'customer_suffix','string',-4,'','sales_flat_quote'));
		$this->add_field(new core_model_field(28,'customer_dob','timestamp',4,'','sales_flat_quote'));
		$this->add_field(new core_model_field(29,'customer_note','string',-4,'','sales_flat_quote'));
		$this->add_field(new core_model_field(30,'customer_note_notify','int',8,'','sales_flat_quote'));
		$this->add_field(new core_model_field(31,'customer_is_guest','int',8,'','sales_flat_quote'));
		$this->add_field(new core_model_field(32,'remote_ip','string',-4,'','sales_flat_quote'));
		$this->add_field(new core_model_field(33,'applied_rule_ids','string',-4,'','sales_flat_quote'));
		$this->add_field(new core_model_field(34,'reserved_order_id','string',-4,'','sales_flat_quote'));
		$this->add_field(new core_model_field(35,'password_hash','string',-4,'','sales_flat_quote'));
		$this->add_field(new core_model_field(36,'coupon_code','string',-4,'','sales_flat_quote'));
		$this->add_field(new core_model_field(37,'quote_status_id','string',-4,'','sales_flat_quote'));
		$this->add_field(new core_model_field(38,'billing_address_id','string',-4,'','sales_flat_quote'));
		$this->add_field(new core_model_field(39,'global_currency_code','string',-4,'','sales_flat_quote'));
		$this->add_field(new core_model_field(40,'base_to_global_rate','float',10,'2','sales_flat_quote'));
		$this->add_field(new core_model_field(41,'base_to_quote_rate','float',10,'2','sales_flat_quote'));
		$this->add_field(new core_model_field(42,'custbalance_amount','string',-4,'','sales_flat_quote'));
		$this->add_field(new core_model_field(43,'is_multi_payment','string',-4,'','sales_flat_quote'));
		$this->add_field(new core_model_field(44,'customer_taxvat','string',-4,'','sales_flat_quote'));
		$this->add_field(new core_model_field(45,'subtotal','float',10,'2','sales_flat_quote'));
		$this->add_field(new core_model_field(46,'base_subtotal','float',10,'2','sales_flat_quote'));
		$this->add_field(new core_model_field(47,'subtotal_with_discount','float',10,'2','sales_flat_quote'));
		$this->add_field(new core_model_field(48,'base_subtotal_with_discount','float',10,'2','sales_flat_quote'));
		$this->add_field(new core_model_field(49,'is_changed','int',8,'','sales_flat_quote'));
		$this->add_field(new core_model_field(50,'trigger_recollect','int',8,'','sales_flat_quote'));
		$this->add_field(new core_model_field(51,'gift_message_id','string',-4,'','sales_flat_quote'));
		$this->add_field(new core_model_field(52,'ext_shipping_info','string',8000,'','sales_flat_quote'));
		$this->add_field(new core_model_field(53,'cart_redemptions','string',8000,'','sales_flat_quote'));
		$this->add_field(new core_model_field(54,'applied_redemptions','string',8000,'','sales_flat_quote'));
		$this->init_data();
	}
}
?>