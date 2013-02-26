<?php
class core_model_base_domains_branding extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'branding_id','int',8,'','domains_branding'));
		$this->add_field(new core_model_field(1,'domain_id','int',8,'','domains_branding'));
		$this->add_field(new core_model_field(2,'header_font','int',8,'','domains_branding'));
		$this->add_field(new core_model_field(3,'text_color','int',8,'','domains_branding'));
		$this->add_field(new core_model_field(4,'background_color','int',8,'','domains_branding'));
		$this->add_field(new core_model_field(5,'background_id','int',8,'','domains_branding'));
		$this->add_field(new core_model_field(6,'is_temp','int',8,'','domains_branding'));
		$this->init_data();
	}
}
?>