<?php
class core_model_base_Taxonomy extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'TAXON_ID','int',8,'','Taxonomy'));
		$this->add_field(new core_model_field(1,'PRODUCT_ID','int',8,'','Taxonomy'));
		$this->add_field(new core_model_field(2,'PARENT_ID','int',8,'','Taxonomy'));
		$this->init_data();
	}
}
?>