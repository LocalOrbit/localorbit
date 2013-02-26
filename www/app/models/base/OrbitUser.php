<?php
class core_model_base_OrbitUser extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'USER_ID','int',8,'','OrbitUser'));
		$this->add_field(new core_model_field(1,'LOGIN_NAME','string',-4,'','OrbitUser'));
		$this->add_field(new core_model_field(2,'PASSWORD','string',-4,'','OrbitUser'));
		$this->add_field(new core_model_field(3,'ACCOUNT_TYPE','int',8,'','OrbitUser'));
		$this->add_field(new core_model_field(4,'FIRST_NAME','string',-4,'','OrbitUser'));
		$this->add_field(new core_model_field(5,'LAST_NAME','string',-4,'','OrbitUser'));
		$this->add_field(new core_model_field(6,'MIDDLE_INITIAL','string',-4,'','OrbitUser'));
		$this->add_field(new core_model_field(7,'ADDRESS_ONE','string',-4,'','OrbitUser'));
		$this->add_field(new core_model_field(8,'ADDRESS_TWO','string',-4,'','OrbitUser'));
		$this->add_field(new core_model_field(9,'CITY','string',-4,'','OrbitUser'));
		$this->add_field(new core_model_field(10,'STATE','string',-4,'','OrbitUser'));
		$this->add_field(new core_model_field(11,'ZIP_CODE','int',8,'','OrbitUser'));
		$this->add_field(new core_model_field(12,'EMAIL','string',-4,'','OrbitUser'));
		$this->add_field(new core_model_field(13,'PHONE','string',-4,'','OrbitUser'));
		$this->add_field(new core_model_field(14,'COMPANY','string',-4,'','OrbitUser'));
		$this->add_field(new core_model_field(15,'SECURITY_QUESTION','string',-4,'','OrbitUser'));
		$this->add_field(new core_model_field(16,'SECURITY_ANSWER','string',-4,'','OrbitUser'));
		$this->add_field(new core_model_field(17,'BANK_NAME','string',-4,'','OrbitUser'));
		$this->add_field(new core_model_field(18,'BANK_ACCOUNT_TYPE','int',8,'','OrbitUser'));
		$this->add_field(new core_model_field(19,'ROUTING_NUMBER','string',-4,'','OrbitUser'));
		$this->add_field(new core_model_field(20,'ACCOUNT_NUMBER','string',-4,'','OrbitUser'));
		$this->add_field(new core_model_field(21,'NOTIFY_BY_EMAIL','string',-4,'','OrbitUser'));
		$this->add_field(new core_model_field(22,'NOTIFY_BY_TEXT','string',-4,'','OrbitUser'));
		$this->add_field(new core_model_field(23,'RECEIVE_NEWS','string',-4,'','OrbitUser'));
		$this->add_field(new core_model_field(24,'CREATED','timestamp','','OrbitUser'));
		$this->add_field(new core_model_field(25,'LAST_LOGIN','timestamp','','OrbitUser'));
		$this->add_field(new core_model_field(26,'VERSION_COUNT','int',8,'','OrbitUser'));
		$this->add_field(new core_model_field(27,'APPROVAL_TYPE','int',8,'','OrbitUser'));
		$this->add_field(new core_model_field(28,'APPROVAL_ID','int',8,'','OrbitUser'));
		$this->add_field(new core_model_field(29,'Entity_Id','int',8,'','OrbitUser'));
		$this->add_field(new core_model_field(30,'TEXT_PHONE','string',-4,'','OrbitUser'));
		$this->add_field(new core_model_field(31,'domain_id','int',8,'','OrbitUser'));
		$this->add_field(new core_model_field(32,'uniqid','string',-4,'','OrbitUser'));
		$this->add_field(new core_model_field(33,'verification_ip','string',-4,'','OrbitUser'));
		$this->add_field(new core_model_field(34,'uniqid_expiry_date','timestamp','','OrbitUser'));
		$this->add_field(new core_model_field(35,'additional_domain_ids','string',-4,'','OrbitUser'));
		$this->init_data();
	}
}
?>