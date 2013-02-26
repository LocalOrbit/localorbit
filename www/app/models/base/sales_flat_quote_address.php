<?php
class core_model_base_sales_flat_quote_address extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'address_id','int',8,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(1,'quote_id','int',8,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(2,'created_at','timestamp',4,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(3,'updated_at','timestamp',4,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(4,'customer_id','int',8,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(5,'save_in_address_book','int',8,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(6,'customer_address_id','int',8,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(7,'address_type','string',-4,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(8,'email','string',-4,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(9,'prefix','string',-4,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(10,'firstname','string',-4,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(11,'middlename','string',-4,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(12,'lastname','string',-4,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(13,'suffix','string',-4,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(14,'company','string',-4,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(15,'street','string',-4,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(16,'city','string',-4,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(17,'region','string',-4,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(18,'region_id','int',8,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(19,'postcode','string',-4,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(20,'country_id','string',-4,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(21,'telephone','string',-4,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(22,'fax','string',-4,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(23,'same_as_billing','int',8,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(24,'free_shipping','int',8,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(25,'collect_shipping_rates','int',8,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(26,'shipping_method','string',-4,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(27,'shipping_description','string',-4,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(28,'weight','float',10,'2','sales_flat_quote_address'));
		$this->add_field(new core_model_field(29,'subtotal','float',10,'2','sales_flat_quote_address'));
		$this->add_field(new core_model_field(30,'base_subtotal','float',10,'2','sales_flat_quote_address'));
		$this->add_field(new core_model_field(31,'subtotal_with_discount','float',10,'2','sales_flat_quote_address'));
		$this->add_field(new core_model_field(32,'base_subtotal_with_discount','float',10,'2','sales_flat_quote_address'));
		$this->add_field(new core_model_field(33,'tax_amount','float',10,'2','sales_flat_quote_address'));
		$this->add_field(new core_model_field(34,'base_tax_amount','float',10,'2','sales_flat_quote_address'));
		$this->add_field(new core_model_field(35,'shipping_amount','float',10,'2','sales_flat_quote_address'));
		$this->add_field(new core_model_field(36,'base_shipping_amount','float',10,'2','sales_flat_quote_address'));
		$this->add_field(new core_model_field(37,'shipping_tax_amount','float',10,'2','sales_flat_quote_address'));
		$this->add_field(new core_model_field(38,'base_shipping_tax_amount','float',10,'2','sales_flat_quote_address'));
		$this->add_field(new core_model_field(39,'discount_amount','float',10,'2','sales_flat_quote_address'));
		$this->add_field(new core_model_field(40,'base_discount_amount','float',10,'2','sales_flat_quote_address'));
		$this->add_field(new core_model_field(41,'grand_total','float',10,'2','sales_flat_quote_address'));
		$this->add_field(new core_model_field(42,'base_grand_total','float',10,'2','sales_flat_quote_address'));
		$this->add_field(new core_model_field(43,'customer_notes','string',8000,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(44,'entity_id','string',-4,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(45,'parent_id','string',-4,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(46,'custbalance_amount','string',-4,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(47,'base_custbalance_amount','string',-4,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(48,'applied_taxes','string',8000,'','sales_flat_quote_address'));
		$this->add_field(new core_model_field(49,'gift_message_id','string',-4,'','sales_flat_quote_address'));
		$this->init_data();
	}
}
?>