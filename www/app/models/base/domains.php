<?php
class core_model_base_domains extends core_model
{
	function init_fields()
	{
		$this->add_field(new core_model_field(0,'domain_id','int',8,'','domains'));
		$this->add_field(new core_model_field(1,'name','string',-4,'','domains'));
		$this->add_field(new core_model_field(2,'hostname','string',-4,'','domains'));
		$this->add_field(new core_model_field(3,'mag_store','string',-4,'','domains'));
		$this->add_field(new core_model_field(4,'is_live','int',8,'','domains'));
		$this->add_field(new core_model_field(5,'due_day','int',8,'','domains'));
		$this->add_field(new core_model_field(6,'ship_day','int',8,'','domains'));
		$this->add_field(new core_model_field(7,'dev_hours','string',-4,'','domains'));
		$this->add_field(new core_model_field(8,'pickup_hours','string',-4,'','domains'));
		$this->add_field(new core_model_field(9,'is_closed','int',8,'','domains'));
		$this->add_field(new core_model_field(10,'allowed_groups','string',-4,'','domains'));
		$this->add_field(new core_model_field(11,'dashboard_note','string',8000,'','domains'));
		$this->add_field(new core_model_field(12,'harvest_day_note','string',8000,'','domains'));
		$this->add_field(new core_model_field(13,'closed_note','string',8000,'','domains'));
		$this->add_field(new core_model_field(14,'fee_percen_lo','float',10,'2','domains'));
		$this->add_field(new core_model_field(15,'fee_percen_hub','float',10,'2','domains'));
		$this->add_field(new core_model_field(16,'payment_allow_authorize','int',8,'','domains'));
		$this->add_field(new core_model_field(17,'payment_allow_purchaseorder','int',8,'','domains'));
		$this->add_field(new core_model_field(18,'dropoff_hours','string',-4,'','domains'));
		$this->add_field(new core_model_field(19,'allow_anonymous_users','int',8,'','domains'));
		$this->add_field(new core_model_field(20,'show_on_homepage','int',8,'','domains'));
		$this->add_field(new core_model_field(21,'detailed_name','string',-4,'','domains'));
		$this->add_field(new core_model_field(22,'has_custom_logo','int',8,'','domains'));
		$this->add_field(new core_model_field(23,'secondary_contact_name','string',-4,'','domains'));
		$this->add_field(new core_model_field(24,'secondary_contact_email','string',-4,'','domains'));
		$this->add_field(new core_model_field(25,'secondary_contact_phone','string',-4,'','domains'));
		$this->add_field(new core_model_field(26,'market_profile','string',8000,'','domains'));
		$this->add_field(new core_model_field(27,'market_policies','string',8000,'','domains'));
		$this->add_field(new core_model_field(28,'custom_tagline','string',-4,'','domains'));
		$this->add_field(new core_model_field(29,'dashboard_section1_title','string',-4,'','domains'));
		$this->add_field(new core_model_field(30,'dashboard_section1_body','string',8000,'','domains'));
		$this->add_field(new core_model_field(31,'dashboard_section2_title','string',-4,'','domains'));
		$this->add_field(new core_model_field(32,'dashboard_section2_body','string',8000,'','domains'));
		$this->add_field(new core_model_field(33,'dashboard_section3_title','string',-4,'','domains'));
		$this->add_field(new core_model_field(34,'dashboard_section3_body','string',8000,'','domains'));
		$this->add_field(new core_model_field(35,'dashboard_section1_show','int',8,'','domains'));
		$this->add_field(new core_model_field(36,'dashboard_section2_show','int',8,'','domains'));
		$this->add_field(new core_model_field(37,'dashboard_section3_show','int',8,'','domains'));
		$this->add_field(new core_model_field(38,'profile_pic_extension','string',-4,'','domains'));
		$this->add_field(new core_model_field(39,'bubble_offset','int',8,'','domains'));
		$this->add_field(new core_model_field(40,'payment_allow_paypal','int',8,'','domains'));
		$this->add_field(new core_model_field(41,'cycle','string',-4,'','domains'));
		$this->add_field(new core_model_field(42,'tz_id','int',8,'','domains'));
		$this->add_field(new core_model_field(43,'do_daylight_savings','int',8,'','domains'));
		$this->add_field(new core_model_field(44,'hub_covers_fees','int',8,'','domains'));
		$this->add_field(new core_model_field(45,'order_minimum','float',10,'2','domains'));
		$this->add_field(new core_model_field(46,'buyer_types_description','string',-4,'','domains'));
		$this->add_field(new core_model_field(47,'po_due_within_days','int',8,'','domains'));
		$this->add_field(new core_model_field(48,'autoactivate_organization','int',8,'','domains'));
		$this->add_field(new core_model_field(49,'feature_require_seller_all_delivery_opts','int',8,'','domains'));
		$this->add_field(new core_model_field(50,'feature_force_items_to_soonest_delivery','int',8,'','domains'));
		$this->add_field(new core_model_field(51,'paypal_processing_fee','float',10,'2','domains'));
		$this->add_field(new core_model_field(52,'payment_default_purchaseorder','int',8,'','domains'));
		$this->add_field(new core_model_field(53,'payment_default_paypal','int',8,'','domains'));
		$this->add_field(new core_model_field(54,'seller_payer','string',-4,'','domains'));
		$this->add_field(new core_model_field(55,'buyer_invoicer','string',-4,'','domains'));
		$this->add_field(new core_model_field(56,'feature_sellers_enter_price_without_fees','int',8,'','domains'));
		$this->add_field(new core_model_field(57,'feature_sellers_cannot_manage_cross_sells','int',8,'','domains'));
		$this->add_field(new core_model_field(58,'feature_sellers_mark_items_delivered','int',8,'','domains'));
		$this->add_field(new core_model_field(59,'feature_allow_anonymous_shopping','int',8,'','domains'));
		$this->add_field(new core_model_field(60,'default_homepage','string',-4,'','domains'));
		$this->add_field(new core_model_field(61,'payables_create_on','string',-4,'','domains'));
		$this->add_field(new core_model_field(62,'service_fee','float',10,'2','domains'));
		$this->add_field(new core_model_field(63,'sfs_id','int',8,'','domains'));
		$this->add_field(new core_model_field(64,'opm_id','int',8,'','domains'));
		$this->add_field(new core_model_field(65,'service_fee_last_paid','timestamp',4,'','domains'));
		$this->add_field(new core_model_field(66,'payable_org_id','int',8,'','domains'));
		$this->add_field(new core_model_field(67,'seller_payment_managed_by','string',-4,'','domains'));
		$this->add_field(new core_model_field(68,'facebook','string',-4,'','domains'));
		$this->add_field(new core_model_field(69,'twitter','string',-4,'','domains'));
		$this->add_field(new core_model_field(70,'social_option_id','int',8,'','domains'));
		$this->add_field(new core_model_field(71,'feature_paymentsportal_enable','int',8,'','domains'));
		$this->add_field(new core_model_field(72,'feature_paymentsportal_bankaccounts','int',8,'','domains'));
		$this->add_field(new core_model_field(73,'payment_default_ach','int',8,'','domains'));
		$this->add_field(new core_model_field(74,'payment_allow_ach','int',8,'','domains'));
		$this->add_field(new core_model_field(75,'address_id','int',8,'','domains'));
		$this->init_data();
	}
}
?>