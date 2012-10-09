    <div class="footer clr">
        <div class="sidebars">
            <div class="footerleft">
                <?php if ( !function_exists('dynamic_sidebar') || !dynamic_sidebar('Left Footbar') ) : ?>
                <h3 class="boxedin">Post Calendar</h3>
                    <?php get_calendar(); ?> 
                <?php endif; ?>
            </div>
            <div class="footermid">
                <?php if ( !function_exists('dynamic_sidebar') || !dynamic_sidebar('Mid Footbar') ) : ?>
                <h3 class="boxedin">Another Blurb, Or Nutshell...</h3>
                <p>This is a great spot to put a small blurb with some information on what your blog is all about. Use a "Text" widget in your "Mid Footbar" sibebar options in Wordpress. Whatever you put in the title will show about and whatever you put as text (or html) will show right here! Or you can put a menu, a calendar, or any list of links you like. The footer is your oyster.</p>
                <?php endif; ?>
            </div>
            <div class="footerright">
                <?php if ( !function_exists('dynamic_sidebar') || !dynamic_sidebar('Right Footbar') ) : ?>
                    <?php wp_list_bookmarks('title_before=<h3 class="boxedin">&title_after=</h3>&category_before=&category_after='); ?>
                <?php endif; ?>
            </div>
        <div class="clr"></div>
        </div>
    </div>
    
    <div class="basement clr">
        <p>&copy; 2009 <a href="<?php echo get_settings('home'); ?>"><?php bloginfo('name');?></a>. All Rights Reserved.</p>
        <p>This blog is powered by <a href="http://wordpress.org/">Wordpress</a> and <a href="http://bryanhelmig.com/magatheme-cool-minimal-wordpress-theme/">Magatheme</a> by <a href="http://bryanhelmig.com/">Bryan Helmig</a>.</p>
        <p><?php wp_footer(); ?></p>
    </div>
</div>
</body>
</html>