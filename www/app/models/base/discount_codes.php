<?php
class core_model_base_discount_codes extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'disc_id','int',8,'','discount_codes'));
		$this->add_field(new core_model_field(1,'code','string',-4,'','discount_codes'));
		$this->add_field(new core_model_field(2,'name','string',-4,'','discount_codes'));
		$this->add_field(new core_model_field(3,'start_date','timestamp',4,'','discount_codes'));
		$this->add_field(new core_model_field(4,'end_date','timestamp',4,'','discount_codes'));
		$this->add_field(new core_model_field(5,'discount_amount','float',10,'2','discount_codes'));
		$this->add_field(new core_model_field(6,'discount_type','string',-4,'','discount_codes'));
		$this->add_field(new core_model_field(7,'bonus_mount','float',10,'2','discount_codes'));
		$this->add_field(new core_model_field(8,'min_order','float',10,'2','discount_codes'));
		$this->add_field(new core_model_field(9,'max_order','float',10,'2','discount_codes'));
		$this->add_field(new core_model_field(10,'nbr_uses_global','int',8,'','discount_codes'));
		$this->add_field(new core_model_field(11,'domain_id','int',8,'','discount_codes'));
		$this->add_field(new core_model_field(12,'restrict_to_product_id','int',8,'','discount_codes'));
		$this->add_field(new core_model_field(13,'creator_user_id','int',8,'','discount_codes'));
		$this->add_field(new core_model_field(14,'restrict_to_seller_org_id','int',8,'','discount_codes'));
		$this->add_field(new core_model_field(15,'restrict_to_buyer_org_id','int',8,'','discount_codes'));
		$this->add_field(new core_model_field(16,'nbr_uses_org','int',8,'','discount_codes'));
		$this->init_data();
	}
}
?>