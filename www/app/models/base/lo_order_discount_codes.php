<?php
class core_model_base_lo_order_discount_codes extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'lodisc_id','int',8,'','lo_order_discount_codes'));
		$this->add_field(new core_model_field(1,'lo_oid','int',8,'','lo_order_discount_codes'));
		$this->add_field(new core_model_field(2,'disc_id','int',8,'','lo_order_discount_codes'));
		$this->add_field(new core_model_field(3,'code','string',-4,'','lo_order_discount_codes'));
		$this->add_field(new core_model_field(4,'discount_amount','float',10,'2','lo_order_discount_codes'));
		$this->add_field(new core_model_field(5,'discount_type','string',-4,'','lo_order_discount_codes'));
		$this->add_field(new core_model_field(6,'restrict_to_product_id','int',8,'','lo_order_discount_codes'));
		$this->add_field(new core_model_field(7,'restrict_to_seller_org_id','int',8,'','lo_order_discount_codes'));
		$this->add_field(new core_model_field(8,'applied_amount','float',10,'2','lo_order_discount_codes'));
		$this->add_field(new core_model_field(9,'restrict_to_buyer_org_id','int',8,'','lo_order_discount_codes'));
		$this->add_field(new core_model_field(10,'min_order','float',10,'2','lo_order_discount_codes'));
		$this->add_field(new core_model_field(11,'max_order','float',10,'2','lo_order_discount_codes'));
		$this->init_data();
	}
}
?>