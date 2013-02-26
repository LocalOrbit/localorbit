<?php
require_once dirname(__FILE__) . '/../Page.php';

/**
 * General configuration options
 *
 * @category   Umapper
 * @package    Umapper_Plugin
 * @copyright  2009 CrabDish
 * @version    Release: 1.0.0
 * @author     Victor Farazdagi <victor@afcomponents.com>
 */
class Umapper_Page_Config extends Umapper_Page
{
    /**
     * Singleton instance. Declared protected so that derived classes can have their own instances.
     * @var Umapper_Page_Config
     */
    protected static $instance = null;

    /**
     * Private consturctor - sigleton pattern
     *
     * @return  void
     */
    private function __construct() {}

    /**
     * Singleton instance
     *
     * @return  mixed
     */
    public function getInstance()
    {
        if(null == self::$instance) {
            self::$instance = new self();
        }
        return self::$instance;
    }

    /**
     * Shows selected view
     *
     * @param   string  $block  Block to show
     * @return  void
     */
    public function show($block = '')
    {
        parent::show($block);
    }

}
