<?

class core_test_20006 extends core_test
{
	function run()
	{
		global $core;
		# this test loads tons of various pages
		# from the admin site to see if they all load
		
		
		if(core_test_request::do_request('newsletters/list')->not_contains('<h1>Newsletters'))
		{
			return $this->fail('newsletters list did not load');
		}
		if(core_test_request::do_request('newsletters/edit',array('cont_id'=>77))->not_contains('<h1>Editing'))
		{
			return $this->fail('newsletters Edit 77 did not load');
		}
		if(core_test_request::do_request('market_news/list')->not_contains('<h1>Market News'))
		{
			return $this->fail('market_news list did not load');
		}
		if(core_test_request::do_request('market_news/edit',array('mnews_id'=>27))->not_contains('<h1>Editing'))
		{
			return $this->fail('market_news Edit 27 did not load');
		}
		if(core_test_request::do_request('weekly_specials/list')->not_contains('<h1>Featured Deals'))
		{
			return $this->fail('weekly_specials list did not load');
		}
		if(core_test_request::do_request('weekly_specials/edit',array('spec_id'=>33))->not_contains('<h1>Editing'))
		{
			return $this->fail('weekly_specials Edit 33 did not load');
		}
		if(core_test_request::do_request('fresh_sheet/review')->not_contains('<h1>Fresh Sheet'))
		{
			return $this->fail('Fresh Sheet list did not load');
		}
		
		return $this->success();
	}
}

?>
