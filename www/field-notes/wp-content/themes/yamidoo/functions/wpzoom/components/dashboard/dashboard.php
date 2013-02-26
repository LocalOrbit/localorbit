<?php
if (wpzoom::$tf) return;

function WPZOOM_Dashboard() {
?>
<div class="table table_news">
    <p class="sub">From our Blog</p>
    <div class="rss-widget">
        <?php
        /**
         * Get RSS Feed(s)
         */

        $items = get_transient('wpzoom_dashboard_widget_news');

        if (!(is_array($items) && count($items))) {
            include_once(ABSPATH . WPINC . '/class-simplepie.php');
            $rss = new SimplePie();
            $rss->set_timeout(5);
            $rss->set_feed_url('http://www.wpzoom.com/feed/');
            $rss->strip_htmltags(array_merge($rss->strip_htmltags, array('h1', 'a', 'img')));
            $rss->enable_cache(false);
            $rss->init();

            $items = $rss->get_items(0, 3);

            $cached = array();
            foreach ($items as $item) {
                $cached[] = array(
                    'url' => $item->get_permalink(),
                    'title' => $item->get_title(),
                    'date' => $item->get_date("d M Y"),
                    'content' => substr(strip_tags($item->get_content()), 0, 128) . "..."
                );
            }

            $items = $cached;
            set_transient('wpzoom_dashboard_widget_news', $cached, 60 * 60 * 24);
        }
        ?>

        <ul class="news">
            <?php if (empty($items)) {
                echo '<li>No items</li>';
            } else {
                foreach ($items as $item) {
            ?>

                <li class="post">
                    <a href="<?php echo $item['url']; ?>" class="rsswidget"><?php echo $item['title']; ?></a>
                    <span class="rss-date"><?php echo $item['date']; ?></span>
                    <div class="rssSummary"><?php echo $item['content']; ?></div>
                </li>

            <?php
                }
            }
            ?>
        </ul><!-- end of .news -->
    </div>
</div>

<div class="table table_theme">
    <p class="sub">Latest Theme</p>
    <div class="theme_thumb">
        <?php
            $lastTheme = get_transient('wpzoom_dashboard_widget_theme');
            if (!$lastTheme) {
                $lastTheme = @file_get_contents('http://www.wpzoom.com/themes/?last-theme=true');
                if ($lastTheme) {
                    set_transient('wpzoom_dashboard_widget_theme', $lastTheme, 60 * 60 * 24);
                }
            }
        ?>

        <?php if ($lastTheme) echo $lastTheme; ?>

    </div>

    <a href="http://wpzoom.com/themes/" target="_blank" alt="Browse our wide selection of WordPress themes to find the right one for you" class="button">Browse more &rarr;</a>
</div>

<div class="clear">&nbsp;</div>
<?php
}

function wpzoom_dashboard_widgets() {
    wp_add_dashboard_widget('dashboard_wpzoom', 'WPZOOM News', 'WPZOOM_Dashboard');

    wp_enqueue_style('dashboard_wpzoom_stylesheet', WPZOOM::$assetsPath . '/css/dashboard.css');

    // Globalize the metaboxes array, this holds all the widgets for wp-admin
    global $wp_meta_boxes;

    // Get the regular dashboard widgets array
    // (which has our new widget already but at the end)

    $normal_dashboard = $wp_meta_boxes['dashboard']['normal']['core'];

    // Backup and delete our new dashbaord widget from the end of the array
    $wpzoom_widget_backup = array('dashboard_wpzoom' => $normal_dashboard['dashboard_wpzoom']);
    unset($normal_dashboard['dashboard_wpzoom']);

    // Merge the two arrays together so our widget is at the beginning
    $sorted_dashboard = array_merge($wpzoom_widget_backup, $normal_dashboard);

    // Save the sorted array back into the original metaboxes
    $wp_meta_boxes['dashboard']['normal']['core'] = $sorted_dashboard;
}

add_action('wp_dashboard_setup', 'wpzoom_dashboard_widgets');
