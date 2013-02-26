core.metrics={};

core.metrics.refreshData=function(){
	var params = {};
	
	params.output_as = document.metricsForm.output_as.value;
	params.start_date = document.metricsForm.start_date.value;
	params.end_date = document.metricsForm.end_date.value;
	params.breakdown_by = document.metricsForm.breakdown_by.options[document.metricsForm.breakdown_by.selectedIndex].value;
	params.domain_id = document.metricsForm.domain_id.options[document.metricsForm.domain_id.selectedIndex].value;
	
	$('#output_area').html('<img src="/img/default/loading-progress.gif" />');
	core.doRequest('/metrics/render_metrics',params);
}

core.metrics.downloadCsv=function(){
	var url = 'app/metrics/render_metrics?output_as=csv';
	url += '&start_date='+encodeURIComponent(document.metricsForm.start_date.value);
	url += '&end_date='+encodeURIComponent(document.metricsForm.end_date.value);
	url += '&breakdown_by='+document.metricsForm.breakdown_by.options[document.metricsForm.breakdown_by.selectedIndex].value;
	url += '&domain_id='+document.metricsForm.domain_id.options[document.metricsForm.domain_id.selectedIndex].value;
	location.href = url;
}