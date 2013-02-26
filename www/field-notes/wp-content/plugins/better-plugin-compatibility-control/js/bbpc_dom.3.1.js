jQuery(document).ready(function() {
	jQuery(".bpcc_wrapper").each(function() {
		var content_e = jQuery(this).html();
		jQuery(this).parent().parent().parent().next().find('.plugin-version-author-uri').append( ' | ' + content_e );
	});
});