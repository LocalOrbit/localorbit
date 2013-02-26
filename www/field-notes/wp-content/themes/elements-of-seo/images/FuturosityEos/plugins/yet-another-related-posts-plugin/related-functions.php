<?php

// Here are the related_WHATEVER functions, as introduced in 1.1, which actually just use the yarpp_related and yarpp_related_exist functions.

function related_posts() {
	$a = func_get_args();
	return yarpp_related(array('post'),$a);
}

function related_pages() {
	$a = func_get_args();
	return yarpp_related(array('page'),$a);
}

function related_entries() {
	$a = func_get_args();
	return yarpp_related(array('page','post'),$a);
}

function related_posts_exist() {
	$a = func_get_args();
	return yarpp_related_exist(array('post'),$a);
}

function related_pages_exist() {
	$a = func_get_args();
	return yarpp_related_exist(array('page'),$a);
}

function related_entries_exist() {
	$a = func_get_args();
	return yarpp_related_exist(array('page','post'),$a);
}

?>