<?php
class core_model_base_sales_flat_quote_address_item extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'address_item_id','int',8,'','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(1,'parent_item_id','int',8,'','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(2,'quote_address_id','int',8,'','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(3,'quote_item_id','int',8,'','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(4,'created_at','timestamp',4,'','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(5,'updated_at','timestamp',4,'','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(6,'applied_rule_ids','string',8000,'','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(7,'additional_data','string',8000,'','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(8,'weight','float',10,'2','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(9,'qty','float',10,'2','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(10,'discount_amount','float',10,'2','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(11,'tax_amount','float',10,'2','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(12,'row_total','float',10,'2','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(13,'base_row_total','float',10,'2','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(14,'row_total_with_discount','float',10,'2','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(15,'base_discount_amount','float',10,'2','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(16,'base_tax_amount','float',10,'2','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(17,'row_weight','float',10,'2','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(18,'parent_id','string',-4,'','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(19,'product_id','string',-4,'','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(20,'super_product_id','string',-4,'','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(21,'parent_product_id','string',-4,'','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(22,'sku','string',-4,'','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(23,'image','string',-4,'','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(24,'name','string',-4,'','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(25,'description','string',-4,'','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(26,'free_shipping','string',-4,'','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(27,'is_qty_decimal','string',-4,'','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(28,'price','string',-4,'','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(29,'discount_percent','string',-4,'','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(30,'no_discount','string',-4,'','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(31,'tax_percent','string',-4,'','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(32,'base_price','string',-4,'','sales_flat_quote_address_item'));
		$this->add_field(new core_model_field(33,'gift_message_id','string',-4,'','sales_flat_quote_address_item'));
		$this->init_data();
	}
}
?>