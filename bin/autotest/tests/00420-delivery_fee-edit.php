<?

class core_test_00420 extends core_test{

   function run() {
       $data = array
(
    '?_reqtime' => 1348062962,
    'dd_id' => 62,
    'domain_id' => 26,
    'cycle' => 'weekly',
    'hours_due_before' => 6,
    'day_ordinal' => null,
    'day_nbr' => 1,
    'deliv_address_id' => 0,
    'delivery_start_time' => 0,
    'delivery_end_time' => 0,
    'pickup_start_time' => 0,
    'pickup_end_time' => 0,
    'pickup_address_id' => 0,
    'allproducts' => 0,
    'allcrosssellproducts' => 0,
    'fee_calc_type_id' => 1,
    'amount' => 15,
    'minimum_order' => undefined,
    'devfee_id' =>undefined 
);
       $req = core_test_request::do_request('market/delivery', array('domain_id' => 26));
	preg_match('/"devfee_id":\s*"(\d+)/',$req->text['js'],$matches);
        $data['devfeed_id'] = $matches[1];
	$req = core_test_request::do_request('market/save_delivery', $data);
       if (!$req->notified('delivery day saved')) {
         $this->fail('Delivery fee was not saved.');
       }
       $req = core_test_request::do_request('market/delivery', array('domain_id' => 26));
       if ($req->not_contains('"fee_calc_type_id": 1,"amount": 15')){
 	 $this->fail('Delivery is not set correctly.');
       }
       $data = array
(
    '?_reqtime' => 1348062962,
    'dd_id' => 62,
    'domain_id' => 26,
    'cycle' => 'weekly',
    'hours_due_before' => 6,
    'day_ordinal' => null,
    'day_nbr' => 1,
    'deliv_address_id' => 0,
    'delivery_start_time' => 0,
    'delivery_end_time' => 0,
    'pickup_start_time' => 0,
    'pickup_end_time' => 0,
    'pickup_address_id' => 0,
    'allproducts' => 0,
    'allcrosssellproducts' => 0,
    'fee_calc_type_id' => 0,
    'amount' => 3,
    'minimum_order' => undefined,
    'devfee_id' => $matches[1]
);
       $req = core_test_request::do_request('market/save_delivery', $data);
       if (!$req->notified('delivery day saved')) {
         $this->fail('Delivery fee was not saved.');
       }
       $req = core_test_request::do_request('market/delivery', array('domain_id' => 26));
       if ($req->not_contains('"fee_calc_type_id": 0,"amount": 3')){
 	 $this->fail('Delivery is not set correctly.');
	}
   }
}
?>
