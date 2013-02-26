<style>
    body {font-size:10px;}
</style>
<script type="text/javascript">
    //<![CDATA[
    jQuery(document).ready(function($){
        $('#message').show('slow');
        $('#message').html('<?php _e('Obtaining UMapper session..', 'umapper');?>');
        umapperAjax.getToken(umapperOptions.rpcKey, function(token){
            // save token
            jQuery.ajax({
                "url": umapperOptions.rpcUri + '?update_option=umapper_token',
                "dataType": 'json',
                "type": "POST",
                "data": token,
                "success": function(resp) {
                    $('#message').html('<?php _e('Done!', 'umapper');?>');
                    window.location = umapperOptions.pluginUri + 'form.php?<?php echo $_SERVER['QUERY_STRING']?>';
                },
                "error":function(){
                    $('#message').html('<?php _e('Request cannot be completed!', 'umapper');?>');
                },
                "processData": false,
                "contentType": "application/json"
            });
        });
    });
    //]]>
</script>
