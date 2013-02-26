<?

class core_test_00415 extends core_test
{
	function run()
	{
$data = array(
	'?_reqtime'=>'1346179468',
	'title'=>'Temporary Item',
	'content'=>'<br>',
	'mnews_id'=>'27',
	'save'=>'',
	'do_redirect'=>'1',
);
		$req = core_test_request::do_request('market_news/update',$data);
		if (!$req->notified('news item saved')) {
			return $this->fail('Does not save temp news item correctly.');
		}
 		if (core_test_request::do_request('market_news/edit', array('mnews_id' => 27))->not_contains('<h1>Editing Temporary Item')) {
			return $this->fail('Does not save temp news item information correctly.');
		}	

$data = array(
	'?_reqtime'=>'1346179468',
	'title'=>'Great News!!!',
	'content'=>'<br>',
	'mnews_id'=>'27',
	'save'=>'',
	'do_redirect'=>'1',
);

		$req = core_test_request::do_request('market_news/update',$data);
		if (!$req->notified('news item saved')) {
			return $this->fail('Does not save temp news item correctly.');
		}
 		if (core_test_request::do_request('market_news/edit', array('mnews_id' => 27))->not_contains('<h1>Editing Great News!!!')) {
			return $this->fail('Does not save temp news item information correctly.');
		}	
	}
}

?>
