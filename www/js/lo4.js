core.lo4 = {};

core.lo4.initRemoveSigns=function(){
	$('.prodTotal_text > i.icon-close').click(function () {
		var jq = $(this);
		var idSplit = jq.parent().attr('id').split('_');
		$('.prodQty_'+idSplit[1]).val(0);
		jq.parent().hide();
		core.catalog.updateRow(idSplit[1], 0,0);
	});
}