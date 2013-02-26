<?php
class core_model_base_delivery_days extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'dd_id','int',8,'','delivery_days'));
		$this->add_field(new core_model_field(1,'domain_id','int',8,'','delivery_days'));
		$this->add_field(new core_model_field(2,'cycle','string',-4,'','delivery_days'));
		$this->add_field(new core_model_field(3,'day_ordinal','int',8,'','delivery_days'));
		$this->add_field(new core_model_field(4,'day_nbr','int',8,'','delivery_days'));
		$this->add_field(new core_model_field(5,'deliv_address_id','int',8,'','delivery_days'));
		$this->add_field(new core_model_field(6,'delivery_start_time','float',10,'2','delivery_days'));
		$this->add_field(new core_model_field(7,'delivery_end_time','float',10,'2','delivery_days'));
		$this->add_field(new core_model_field(8,'pickup_start_time','float',10,'2','delivery_days'));
		$this->add_field(new core_model_field(9,'pickup_end_time','float',10,'2','delivery_days'));
		$this->add_field(new core_model_field(10,'hours_due_before','int',8,'','delivery_days'));
		$this->add_field(new core_model_field(11,'pickup_address_id','int',8,'','delivery_days'));
		$this->init_data();
	}
}
?>