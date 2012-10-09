<?php
class core_model_base_lo_order_modifiers extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'mod_id','int',8,'','lo_order_modifiers'));
		$this->add_field(new core_model_field(1,'lo_oid','int',8,'','lo_order_modifiers'));
		$this->add_field(new core_model_field(2,'mod_type_id','int',8,'','lo_order_modifiers'));
		$this->add_field(new core_model_field(3,'mod_ref_id','int',8,'','lo_order_modifiers'));
		$this->add_field(new core_model_field(4,'mod_amount','float',10,'2','lo_order_modifiers'));
		$this->add_field(new core_model_field(5,'mod_type','string',-4,'','lo_order_modifiers'));
		$this->add_field(new core_model_field(6,'applies_to_items','string',-4,'','lo_order_modifiers'));
		$this->add_field(new core_model_field(7,'applies_to_fulfill_orders','string',-4,'','lo_order_modifiers'));
		$this->add_field(new core_model_field(8,'applies_to_order','string',-4,'','lo_order_modifiers'));
		$this->add_field(new core_model_field(9,'source_user_id','int',8,'','lo_order_modifiers'));
		$this->add_field(new core_model_field(10,'creation_date','timestamp',4,'','lo_order_modifiers'));
		$this->add_field(new core_model_field(11,'description','string',8000,'','lo_order_modifiers'));
		$this->init_data();
	}
}
?>