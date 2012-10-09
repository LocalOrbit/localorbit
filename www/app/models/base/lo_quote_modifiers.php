<?php
class core_model_base_lo_quote_modifiers extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'qmod_id','int',8,'','lo_quote_modifiers'));
		$this->add_field(new core_model_field(1,'quote_id','int',8,'','lo_quote_modifiers'));
		$this->add_field(new core_model_field(2,'mod_type_id','int',8,'','lo_quote_modifiers'));
		$this->add_field(new core_model_field(3,'mod_ref_id','int',8,'','lo_quote_modifiers'));
		$this->add_field(new core_model_field(4,'mod_amount','float',10,'2','lo_quote_modifiers'));
		$this->add_field(new core_model_field(5,'mod_type','string',-4,'','lo_quote_modifiers'));
		$this->add_field(new core_model_field(6,'applies_to_items','string',-4,'','lo_quote_modifiers'));
		$this->add_field(new core_model_field(7,'applies_to_fulfill_orders','string',-4,'','lo_quote_modifiers'));
		$this->add_field(new core_model_field(8,'applies_to_quote','string',-4,'','lo_quote_modifiers'));
		$this->add_field(new core_model_field(9,'source_user_id','int',8,'','lo_quote_modifiers'));
		$this->add_field(new core_model_field(10,'creation_date','timestamp',4,'','lo_quote_modifiers'));
		$this->add_field(new core_model_field(11,'description','string',8000,'','lo_quote_modifiers'));
		$this->init_data();
	}
}
?>