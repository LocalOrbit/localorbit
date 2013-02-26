<style>
    ul.inline li {float: left; display: inline; padding: 0; margin: 0 10px 0 0; }
    ul.news {}
    ul.news li.post {background-color: #f1f1f1; border: solid 2px #ddd; padding: 15px;}
    ul.news h5 {font-size: 18px; }
    div.cleaner {clear: left; }
    div#features li {float: left; display: inline; margin: 0 20px 15px 0; }
    div#features li img {margin: 0 10px 5px 0; }        
</style>
<div class="wrap">
    <h2>More from WPZOOM</h2>
    <ul class="inline">
        <li><a href="http://www.wpzoom.com/themes/">More Themes</a></li>
        <li><a href="http://www.wpzoom.com/support/">Support</a></li>
        <li><a href="http://www.wpzoom.com/category/showcase/">Theme Showcase</a></li>
    </ul>
    <div class="cleaner">&nbsp;</div>

    <?php
    /**
     * Get RSS Feed(s)
     */
    include_once(ABSPATH . WPINC . '/class-simplepie.php');
    $rss = new SimplePie();
    $rss->set_feed_url('http://www.wpzoom.com/feed/');
    $rss->enable_cache(false);
    $rss->init();
    
    $maxitems = 20;
    $items = array_slice($rss->get_items(), 0, $maxitems);
    ?>
    
    <ul class="news">
        <?php if (empty($items)) {
            echo '<li>No items</li>';
        } else {
            foreach ($items as $item) {
        ?>
        
            <li class="post">
                <h2><a href="<?php echo $item->get_permalink(); ?>"><?php echo $item->get_title(); ?></a></h2><br />
                <?php echo $item->get_content(); ?>
            </li>
        
        <?php
            } 
        }
        ?>
    </ul><!-- end of .news -->
</div><!-- end of .wrap -->
