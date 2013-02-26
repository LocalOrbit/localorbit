<?

class core_test_20405 extends core_test
{
	function run()
	{
 $data = array(
        '?_reqtime'=>'1346168352',
        'name'=>'test',
        'domain_id'=>'26',
        'allow_sell'=>'1',
        'label'=>'Default',
        'address'=>'123 Anywhere',
        'city'=>'Ann Arbor',
        'region_id'=>'33',
        'postal_code'=>'48820',
        'telephone'=>'5175551234',
        'fax'=>'',
        'save'=>'',
);
		$req = core_test_request::do_request('organizations/add_new',$data);
		if (!$req->notified('organization created')) {
			return $this->fail('Does not save temp organization information correctly.');
		}
		preg_match('/org_id-(\d+)/',$req->text['js'],$matches);
		$org_id = $matches[1];
 		if (core_test_request::do_request('organizations/edit', array('org_id' => $org_id))->not_contains('<h1>Editing test')) {
			return $this->fail('Does not save temp user information correctly.');
		}
		core_db::query('delete FROM localorb_www_testing.organizations where org_id =' . $org_id . ';');
	}
}

?>
