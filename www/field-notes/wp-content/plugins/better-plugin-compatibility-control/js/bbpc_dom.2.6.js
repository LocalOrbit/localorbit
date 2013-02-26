jQuery(document).ready(function() {
	//alert( jQuery(".bpcc_wrapper:first").html() );
	jQuery(".bpcc_wrapper").each(function() {
		var content_e = jQuery(this).html();
		jQuery(this).parent().prev().prev().prev().append( '<br />' + content_e );
	});
});