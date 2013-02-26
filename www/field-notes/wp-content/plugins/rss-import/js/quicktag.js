<script type="text/javascript">
		//<![CDATA[
		var length = edButtons.length;
		edButtons[length] = new edButton('RSSImport', '$context', '[RSSImport display="5" feedurl="http://feedurl.com/" before_desc="<br />" displaydescriptions="TRUE" after_desc=" " html="FALSE" truncatedescchar="200" truncatedescstring=" ... " truncatetitlechar=" " truncatetitlestring=" ... " before_date=" <small>" date="FALSE" after_date="</small>" date_format="" before_creator=" <small>" creator="FALSE" after_creator="</small>" start_items="<ul>" end_items="</ul>" start_item="<li>" end_item="</li>" target="" rel="" desc4title="" charsetscan="FALSE" debug="FALSE" before_noitems="<p>" noitems="No items, feed is empty." after_noitems="</p>" before_error="<p>" error="Error: Feed has a error or is not valid" after_error="</p>" paging="FALSE" prev_paging_link="&laquo; Previous" next_paging_link="Next &raquo;" prev_paging_title="more items" next_paging_title="more items" use_simplepie="FALSE"]', '', '');
		function RSSImport_tag(id) {
			id = id.replace(/RSSImport_/, '');
			edInsertTag(edCanvas, id);
		}
		jQuery(document).ready(function() {
			content = '<input id="RSSImport_'+length+'" class="ed_button" type="button" value="' . __( 'RSSImport', FB_RSSI_TEXTDOMAIN ) . '" title="' . __( 'Import a feed with RSSImport', FB_RSSI_TEXTDOMAIN ) . '" onclick="RSSImport_tag(this.id);" />';
			jQuery("#ed_toolbar").append(content);
		});
		//]]>
	</script>	