<?php
class core_model_base_newsletter_archive extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'archive_id','int',8,'','newsletter_archive'));
		$this->add_field(new core_model_field(1,'store_id','int',8,'','newsletter_archive'));
		$this->add_field(new core_model_field(2,'title','string',-4,'','newsletter_archive'));
		$this->add_field(new core_model_field(3,'body','string',8000,'','newsletter_archive'));
		$this->add_field(new core_model_field(4,'sent_on','timestamp',4,'','newsletter_archive'));
		$this->init_data();
	}
}
?>