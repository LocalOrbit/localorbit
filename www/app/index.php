<?php
global $core;
include(dirname(__FILE__).'/core/core.php');
core::init(__FILE__);
core::process();
core::deinit();
?>
