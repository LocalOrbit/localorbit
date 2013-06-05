<?php
class core_model_base_v_payables extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'payable_id','int',8,'','v_payables'));
		$this->add_field(new core_model_field(1,'domain_id','int',8,'','v_payables'));
		$this->add_field(new core_model_field(2,'from_org_id','int',8,'','v_payables'));
		$this->add_field(new core_model_field(3,'to_org_id','int',8,'','v_payables'));
		$this->add_field(new core_model_field(4,'payable_type','string',-4,'','v_payables'));
		$this->add_field(new core_model_field(5,'parent_obj_id','int',8,'','v_payables'));
		$this->add_field(new core_model_field(6,'amount','float',10,'2','v_payables'));
		$this->add_field(new core_model_field(7,'invoice_id','int',8,'','v_payables'));
		$this->add_field(new core_model_field(8,'creation_date','int',8,'','v_payables'));
		$this->add_field(new core_model_field(9,'from_org_name','string',-4,'','v_payables'));
		$this->add_field(new core_model_field(10,'to_org_name','string',-4,'','v_payables'));
		$this->add_field(new core_model_field(11,'from_domain_id','int',8,'','v_payables'));
		$this->add_field(new core_model_field(12,'to_domain_id','int',8,'','v_payables'));
		$this->add_field(new core_model_field(13,'due_date','int',8,'','v_payables'));
		$this->add_field(new core_model_field(14,'invoice_date','int',8,'','v_payables'));
		$this->add_field(new core_model_field(15,'order_nbr','string',-4,'','v_payables'));
		$this->add_field(new core_model_field(16,'days_left','int',8,'','v_payables'));
		$this->add_field(new core_model_field(17,'payable_info','string',8000,'','v_payables'));
		$this->add_field(new core_model_field(18,'delivery_start_time','int',8,'','v_payables'));
		$this->add_field(new core_model_field(19,'delivery_end_time','int',8,'','v_payables'));
		$this->add_field(new core_model_field(20,'amount_paid','float',10,'2','v_payables'));
		$this->add_field(new core_model_field(21,'po_number','string',-4,'','v_payables'));
		$this->add_field(new core_model_field(22,'invoiced','int',8,'','v_payables'));
		$this->add_field(new core_model_field(23,'last_invoiced','int',8,'','v_payables'));
		$this->add_field(new core_model_field(24,'po_terms','int',8,'','v_payables'));
		$this->add_field(new core_model_field(25,'delivery_status','string',-4,'','v_payables'));
		$this->add_field(new core_model_field(26,'payable_status','string',-4,'','v_payables'));
		$this->add_field(new core_model_field(27,'receivable_status','string',-4,'','v_payables'));
		$this->add_field(new core_model_field(28,'payment_status','string',-4,'','v_payables'));
		$this->add_field(new core_model_field(29,'pending','string',-4,'','v_payables'));
		$this->add_field(new core_model_field(30,'searchable_fields','string',8000,'','v_payables'));
		$this->init_data();
	}
}
?>