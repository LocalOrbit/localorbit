<?php
class core_model_base_versions_products extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'v_prod_id','int',8,'','versions_products'));
		$this->add_field(new core_model_field(1,'start_date','timestamp',4,'','versions_products'));
		$this->add_field(new core_model_field(2,'end_date','timestamp',4,'','versions_products'));
		$this->add_field(new core_model_field(3,'prod_id','int',8,'','versions_products'));
		$this->add_field(new core_model_field(4,'org_id','int',8,'','versions_products'));
		$this->add_field(new core_model_field(5,'unit_id','int',8,'','versions_products'));
		$this->add_field(new core_model_field(6,'name','string',-4,'','versions_products'));
		$this->add_field(new core_model_field(7,'description','string',8000,'','versions_products'));
		$this->add_field(new core_model_field(8,'how','string',8000,'','versions_products'));
		$this->add_field(new core_model_field(9,'category_ids','string',-4,'','versions_products'));
		$this->add_field(new core_model_field(10,'final_cat_id','string',-4,'','versions_products'));
		$this->add_field(new core_model_field(11,'addr_id','int',8,'','versions_products'));
		$this->add_field(new core_model_field(12,'label','string',-4,'','versions_products'));
		$this->add_field(new core_model_field(13,'address','string',-4,'','versions_products'));
		$this->add_field(new core_model_field(14,'city','string',-4,'','versions_products'));
		$this->add_field(new core_model_field(15,'region_id','int',8,'','versions_products'));
		$this->add_field(new core_model_field(16,'postal_code','string',-4,'','versions_products'));
		$this->add_field(new core_model_field(17,'telephone','string',-4,'','versions_products'));
		$this->add_field(new core_model_field(18,'fax','string',-4,'','versions_products'));
		$this->add_field(new core_model_field(19,'default_billing','int',8,'','versions_products'));
		$this->add_field(new core_model_field(20,'default_shipping','int',8,'','versions_products'));
		$this->add_field(new core_model_field(21,'delivery_instructions','string',8000,'','versions_products'));
		$this->add_field(new core_model_field(22,'longitude','string',-4,'','versions_products'));
		$this->add_field(new core_model_field(23,'latitude','string',-4,'','versions_products'));
		$this->add_field(new core_model_field(24,'inventory_qty','float',10,'2','versions_products'));
		$this->add_field(new core_model_field(25,'who','string',8000,'','versions_products'));
		$this->init_data();
	}
}
?>