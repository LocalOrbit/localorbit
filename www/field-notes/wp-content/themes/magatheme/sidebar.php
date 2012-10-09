    <div class="sidebars">
        <div class="sidebar2">
            <?php if ( !function_exists('dynamic_sidebar') || !dynamic_sidebar('Wide Sidebar') ) : ?>
            <div class="block">
                <h3 class="boxedin">Us in a nutshell..</h3>
                <p>This is a great spot to put a small blurb with some information on what your blog is all about. Use a "Text" widget in your "Wide Sidebar" sibebar options in Wordpress. Whatever you put in the title will show about and whatever you put as text (or html) will show right here!</p>
                <p>A handy thing about the sidebars in this theme is that they are split into multiple sidebars, and they are all labeled nice and neatly in the options. There is a Wide, Left and Right Sidebar, along with a Left, Mid, and Right Footbar (scroll down!). You can place anything into any of them!</p>
            </div>
            <?php endif; ?>
        </div>
                
        <div class="sidebar3">
            <?php if ( !function_exists('dynamic_sidebar') || !dynamic_sidebar('Left Sidebar') ) : ?>
            <div class="block">
                <h3 class="boxedin">Recent Posts</h3>
                    <?php query_posts('showposts=5'); ?>
                    <ul>
                        <?php while (have_posts()) : the_post(); ?>
                        <li><a href="<?php the_permalink() ?>"><?php the_title(); ?></a></li>
                        <?php endwhile;?>
                    </ul>
            </div>
            <div class="block">
                <h3 class="boxedin">Post Archives</h3>
                    <ul>
                    <?php wp_get_archives('type=monthly'); ?>
                    </ul>
				</div>
            <?php endif; ?>
        </div>
        
        <div class="sidebar3">
            <?php if ( !function_exists('dynamic_sidebar') || !dynamic_sidebar('Right Sidebar') ) : ?>
            <div class="block">
                <h3 class="boxedin">Categories</h3>
                    <ul>
                        <?php wp_list_categories('title_li='); ?>
                    </ul>
            </div>            
            <div class="block">
                <h3 class="boxedin">Meta</h3>
                    <ul>
                        <?php wp_register(); ?>
                        <li><?php wp_loginout(); ?></li>
                        <li><a href="<?php bloginfo('rss2_url'); ?>">RSS</a></li>
                        <li><a href="<?php bloginfo('comments_rss2_url'); ?>">Comment RSS</a></li>
                        <li><a rel="nofollow" href="http://validator.w3.org/check/referer">Valid XHTML</a></li>
                        <?php wp_meta(); ?>
                    </ul>
            </div>
            <?php endif; ?>
        </div>
    </div>