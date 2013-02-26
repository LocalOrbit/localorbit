<?php
/**
 * Everything necessary to support AJAX on plugin's PHP side is abstracted here
 *
 * @category   Wordpress
 * @package    Umapper_Ajax
 * @copyright  2008 Advanced Flash Components
 * @version    1.0.0
 */

/**
 * Zend_XmlRpc_Client
 */
require_once 'Zend/XmlRpc/Client.php';

/**
 * Umapper_Messages
 */
require_once 'Umapper/Messages.php';

/**
 * @category   Wordpress
 * @package    Umapper_Ajax
 * @copyright  2008 Advanced Flash Components
 * @version    Release: 1.0.0
 * @author     Victor Farazdagi <victor@afcomponents.com>
 */ 
class Umapper_Ajax
{
    /**
     * Singleton instance.
     *
     * Set as protected to allow extension of the class. To extend simply override the {@link getInstance()}
     * @var Umapper_Ajax
     */
    protected static $_instance;

    /**
     * RPC client object (link to MAPS service)
     *
     * @var Zend_XmlRpc_Client
     */
    protected static $_rpcClientMaps;
    
    /**
     * RPC client object (link to INTEGRATOR service)
     *
     * @var Zend_XmlRpc_Client
     */
    protected static $_rpcClientIntegrator;
    
    /**
     * @return void
     */
    public function __construct() 
    {
        self::$_rpcClientMaps = new Zend_XmlRpc_Client('http://www.umapper.com/services/xmlrpc/');
        self::$_rpcClientIntegrator = new Zend_XmlRpc_Client('http://www.umapper.com/services/xmlrpc/integrator/');
        
    }
    /**
     * Returns sigleton instance
     *
     * @return Umapper_Ajax
     */
    public static function getInstance() 
    {
        if (null == self::$_instance) {
            self::$_instance = new Umapper_Ajax();
        }
        return self::$_instance;
    }
    
    /**
     * Returns user credentials (session token) for a given api key
     *
     * @param string $key API-key
     * @return string
     */
    private function getToken($key) 
    {
        $client = self::$_rpcClientMaps;
        try {
            $token = $client->call('maps.connectByKey', array($key));
        } catch (Exception $e){
            echo $e->getMessage();
        }
        return $token;
    }
    
    /**
     * Verifies api key, and displays status message
     *
     * @param  string $key API-key to verify
     * @return void
     */
    public function verifyApiKey($key) 
    {
        $client = self::$_rpcClientMaps;
        try {
            if ($client->call('maps.verifyApiKey', array($key))) {
                echo Umapper_Messages::getInstance()->infoMessage('API_KEY_VALID');
            } else {
                echo Umapper_Messages::getInstance()->infoMessage('API_KEY_INVALID');
            }
        } catch (Exception $e){
            echo $e->getMessage();
        }
    }
    
    /**
     * Verifies INTEGRATOR's data, and displays status message
     *
     * @param  string $key API-key to verify
     * @return void
     */
    public function testConnection($user, $pass, $key) 
    {
        $client = self::$_rpcClientIntegrator;
        try {
            if ($res = $client->call('api.connect', array($user, md5($pass), $key))) {
                echo Umapper_Messages::getInstance()->infoMessage('API_DATA_VALID');
            }
        } catch (Exception $e){
            echo $e->getMessage();
        }
    }
    
    /**
     * Invokes saveMapMeta call
     *
     * @param string $key       API-key
     * @param string $mapId     ID of map to be updated
     * @param string $mapTitle  Map title
     * @param string $mapDesc   Map description
     * @return void
     */
    public function saveMapMeta($key, $mapId, $mapTitle, $mapDesc, $providerId) 
    {
        $client = self::$_rpcClientMaps;
        $mapId = (int)$mapId;
        
        // obtain credentials
        $token = $this->getToken($key);
        try {
            if ($client->call('maps.saveMapMeta', array($token, $key, $mapId, array('mapTitle'=>$mapTitle, 'mapDesc'=>$mapDesc, 'providerId'=>$providerId)))) {
                echo Umapper_Messages::getInstance()->info(Umapper_Messages::getInstance()->getMessage('MAP_META_SAVED', 'txt'));
            } else {
                echo Umapper_Messages::getInstance()->info(Umapper_Messages::getInstance()->getMessage('MAP_META_SAVE_FAILED', 'txt'));
            }
        } catch (Exception $e){
            echo $e->getMessage();
        }
        
    }
    
    /**
     * Creates new map on umapper server
     *
     * @param string $key       API-key
     * @param string $mapTitle  Map title
     * @param string $mapDesc   Map description
     * @return void
     */
    public function createMap($key, $mapTitle, $mapDesc, $providerId) 
    {
        $client = self::$_rpcClientMaps;
        try {
            // obtain credentials
            $token = $this->getToken($key);
            if ($token) {
                $response = $client->call('maps.createMap', array($token, $key, array('mapTitle' => $mapTitle, 'mapDesc' => $mapDesc, 'providerId' => $providerId)));                
            }
            echo $response;
        } catch (Exception $e){
            echo $e->getMessage();
        }
        
    }

    /**
     * Deletes selected map on umapper server
     *
     * @param string $key       API-key
     * @param string $mapId     ID of map to delete
     * @return void
     */
    public function deleteMap($key, $mapId) 
    {
        $client = self::$_rpcClientMaps;
        try {
            // obtain credentials
            $token = $this->getToken($key);
            if ($token) {
                $response = $client->call('maps.deleteMap', array($token, $key, (int)$mapId));
            }
            echo $response;
        } catch (Exception $e){
            echo $e->getMessage();
        }
        
    }
    
    /**
     * Invokes requested AJAX methods (if they are present)
     *
     * @param string $method    Call method
     * @param array  $args      Arguments
     * @return string
     */
    public function __call($method, $args) 
    {
        $client = self::$_rpcClientMaps;
        
        if (!isset($args[0])) {
            die('Method undefined..');
        }
        
        try {
            $response = $client->call('maps.' . $args[0], $args[1]);
            Zend_Debug::dump($response);
        } catch (Exception $e){
            echo $e->getMessage();
        }
    }
    
}