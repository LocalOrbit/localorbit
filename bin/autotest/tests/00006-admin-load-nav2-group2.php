<?

class core_test_00006 extends core_test
{
	function run()
	{
		global $core;
		# this test loads tons of various pages
		# from the admin site to see if they all load
		
		
		if(core_test_request::do_request('discount_codes/list')->not_contains('<h1>Discount Codes'))
		{
			return $this->fail('Discount Codes list did not load');
		}
		if(core_test_request::do_request('discount_codes/edit',array('disc_id'=>5))->not_contains('<h1>Editing'))
		{
			return $this->fail('Discount Codes edit 5 did not load');
		}
		if(core_test_request::do_request('newsletters/list')->not_contains('<h1>Newsletters'))
		{
			return $this->fail('newsletters list did not load');
		}
		if(core_test_request::do_request('newsletters/edit',array('cont_id'=>2))->not_contains('<h1>Editing'))
		{
			return $this->fail('newsletters Edit 2 did not load');
		}
		if(core_test_request::do_request('market_news/list')->not_contains('<h1>Market News'))
		{
			return $this->fail('market_news list did not load');
		}
		if(core_test_request::do_request('market_news/edit',array('mnews_id'=>26))->not_contains('<h1>Editing'))
		{
			return $this->fail('market_news Edit 26 did not load');
		}
		if(core_test_request::do_request('weekly_specials/list')->not_contains('<h1>Featured Deals'))
		{
			return $this->fail('weekly_specials list did not load');
		}
		if(core_test_request::do_request('weekly_specials/edit',array('spec_id'=>1))->not_contains('<h1>Editing'))
		{
			return $this->fail('weekly_specials Edit 1 did not load');
		}
		if(core_test_request::do_request('fresh_sheet/review')->not_contains('<h1>Fresh Sheet'))
		{
			return $this->fail('Fresh Sheet list did not load');
		}
		if(core_test_request::do_request('fresh_sheet/review',array('domain_id'=>10))->not_contains('send test'))
		{
			return $this->fail('Fresh Sheet view did not load');
		}
		
		return $this->success();
	}
}

?>