<?php
/**
 * Make sure that plugin DIR is in include_path
 */
set_include_path(realpath(dirname(__FILE__)) . PATH_SEPARATOR . get_include_path());

/**
 * Zend_Debug
 */
require_once 'Zend/Debug.php';

/**
 * Umapper_Patterns_Delegator
 */
require_once 'Umapper/Patterns/Delegator.php';

/**
 * Process AJAX requests
 */
if (isset($_POST['ajax']) && isset($_POST['method'])) {
    require_once 'Umapper/Ajax.php';
    $umapperAjax = Umapper_Ajax::getInstance();
    
    $method = $_POST['method'];
    
    // unset uneccessary parameters
    unset($_POST['method']);
    unset($_POST['ajax']);
    if (isset($_POST['rndval'])) {
        unset($_POST['rndval']);
    }
    
    // make sure that if call exists it is invoked otherwise magic __call should be used
    $r = new ReflectionClass($umapperAjax);
    try {
        $m = $r->getMethod($method);
        $m->invokeArgs($umapperAjax, $_POST);
    } catch (Exception $e){
        $umapperAjax->invoke($method, $_POST); // there's no such method __call() magic method handles the call
    }
} else {
    echo '..';
}
