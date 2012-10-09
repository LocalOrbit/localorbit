#!/usr/bin/php
<?

include('framework/core_testing.php');
core_testing::init(
	dirname(__file__),
	dirname(__file__).'/../../www/app/core/core.php',
	'http://testing.localorb.it/',
	'app/'
);
core_testing::run();
?>