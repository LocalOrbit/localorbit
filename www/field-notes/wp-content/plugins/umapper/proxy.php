<?php
if(!isset($HTTP_RAW_POST_DATA)) {
    die('No data sent..');
}

if(strpos($_GET['url'], 'update_option')) {
    $opts = array();
    parse_str(parse_url($_GET['url'], PHP_URL_QUERY), $opts);
    
    /** Load WordPress Bootstrap */
    require_once(dirname(__FILE__) . '/../../../wp-load.php');
    /** Load WordPress Administration Bootstrap */
    require_once(dirname(__FILE__) . '/../../../wp-admin/admin.php');

    if (!current_user_can('manage_options'))
    wp_die(__('You do not have sufficient permissions to access this page.', 'umapper'));

    if(isset($opts['update_option']) && in_array($opts['update_option'], array('umapper_providers', 'umapper_templates', 'umapper_token'))) {
        $opt = $opts['update_option'];
        if(!get_option($opt)) {
            add_option($opt, $HTTP_RAW_POST_DATA);
        } else {
            update_option($opt, $HTTP_RAW_POST_DATA);
        }

        echo json_encode($opt . ' saved..');
    }
    exit;
}

$post_data = $HTTP_RAW_POST_DATA;

$header[] = "Content-type: text/xml";
$header[] = "Content-length: ".strlen($post_data);

$ch = curl_init( $_GET['url'] );
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1); // we need to return response
curl_setopt($ch, CURLOPT_HEADER, false); // we don't need to return headers
curl_setopt($ch, CURLOPT_TIMEOUT, 10);
curl_setopt($ch, CURLOPT_HTTPHEADER, $header);

if ( strlen($post_data)>0 ){
    curl_setopt($ch, CURLOPT_POSTFIELDS, $post_data);
}

$response = curl_exec($ch);

header("Content-Type: text/xml");
if (curl_errno($ch)) {
    ?>
<&lt;xml version="1.0" encoding="UTF-8"?>
<methodResponse>
    <fault>
        <value>
            <struct>
                <member><name>faultCode</name><value><int>1</int></value></member>
                <member><name>faultString</name><value><string><?php echo curl_error($ch);?></string></value></member>
            </struct>
        </value>
    </fault>
</methodResponse>
<?php
}else {
    curl_close($ch);
    print $response;
}


?>

