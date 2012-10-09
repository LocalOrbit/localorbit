jQuery(document).ready(function() {
	jQuery(".bpcc_wrapper").each(function() {
		var content_e = jQuery(this).html();
		jQuery(this).parent().append( content_e );
	});
});