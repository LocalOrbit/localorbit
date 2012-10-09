<?php
class core_model_base_transactions extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'trans_id','int',8,'','transactions'));
		$this->add_field(new core_model_field(1,'creation_date','timestamp',4,'','transactions'));
		$this->add_field(new core_model_field(2,'amount','float',10,'2','transactions'));
		$this->add_field(new core_model_field(3,'ttype_id','int',8,'','transactions'));
		$this->add_field(new core_model_field(4,'ref1_id','int',8,'','transactions'));
		$this->add_field(new core_model_field(5,'ref2_id','int',8,'','transactions'));
		$this->add_field(new core_model_field(6,'ref3_id','int',8,'','transactions'));
		$this->add_field(new core_model_field(7,'pmethod_id','int',8,'','transactions'));
		$this->add_field(new core_model_field(8,'pay_ref1_id','int',8,'','transactions'));
		$this->add_field(new core_model_field(9,'pay_ref2_id','int',8,'','transactions'));
		$this->init_data();
	}
}
?>