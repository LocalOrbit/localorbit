<?

class core_test_20416 extends core_test
{
	function run()
	{
$data = array(
	'?_reqtime'=>'1346183298',
	'title'=>'Temporary Item',
	'content'=>'<br>',
   'domain_id'=>'26',
	'mnews_id'=>'',
	'save'=>'',
	'do_redirect'=>'1',
);

		$req = core_test_request::do_request('market_news/update',$data);
		if (!$req->notified('news item saved')) {
			return $this->fail('Does not save news item information.');
		}		
		preg_match('/mnews_id\.value=(\d+)/',$req->text['js'],$matches);
		$mnews_id = $matches[1];
		$req = core_test_request::do_request('market_news/edit', array('mnews_id' => $mnews_id));
		if ($req->not_contains('<h1>Editing Temporary Item')) {
			return $this->fail('Does not save temp news item information correctly.');
		}
      if (!core_test_request::do_request('market_news/delete', array('mnews_id' => $mnews_id))->notified('market news deleted')) {
              return $this->fail('Does not delete temp news item information correctly.');
      }
	}
}

?>
