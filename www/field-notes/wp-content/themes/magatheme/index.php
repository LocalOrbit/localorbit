<?php get_header(); ?>
    <div class="main">
    <?php if (have_posts()) : while (have_posts()) : the_post(); ?>
        <div class="article">
            <ul class="extendspost">
                <li>Author: <?php the_author_posts_link(); ?></li>
                <li>Published: <strong><?php the_time('M jS, Y'); ?></strong></li>
                <li>Category: <?php the_category(', ') ?></li>
                <li>Comments: <?php comments_popup_link('None', '1', '%'); ?></li>
            </ul>
            <h1><a href="<?php the_permalink() ?>"><?php the_title(); ?></a></h1>
            <div class="clr marginbottom"></div>
            <p class="tags"><?php if ( has_tag() ) { the_tags('Tags: ', ', ', ''); } else { ?><em>TAGS:</em> <a href="<?php the_permalink(); ?>">None</a><?php } ?></p>
            <div class="content">
            <?php the_content('Read the rest of this entry &raquo;'); ?>
            <div class="solidline margintop"></div>
            </div>
            <?php comments_template(); ?>
        </div>
    <div class="clr"></div>
		
    <?php endwhile; ?>

    <div class="navigation">
        <div class="alignleft"><?php next_posts_link('&laquo; Older Entries') ?></div>
        <div class="alignright"><?php previous_posts_link('Newer Entries &raquo;') ?></div>
    </div>
    
    <?php else : ?>
    <div class="article">
        <ul class="extendspost">
            <li>Author: <a href="<?php echo get_settings('home'); ?>">404 Master</a></li>
            <li>Published: <a href="<?php echo get_settings('home'); ?>">Apr. 4, 404 BC</a></li>
            <li>Category: <a href="<?php echo get_settings('home'); ?>">Can't</a>, <a href="<?php echo get_settings('home'); ?>">Find</a>, <a href="<?php echo get_settings('home'); ?>">It</a></li>
            <li>Comments: <a href="<?php echo get_settings('home'); ?>">None</a></li>
        </ul>
        <h1>Oh no! Article not found! 404 error!</h1>
        <div class="clr marginbottom"></div>
        <p class="tags"><em>TAGS:</em> <a href="<?php echo get_settings('home'); ?>">Are</a>, <a href="<?php echo get_settings('home'); ?>">You</a>, <a href="<?php echo get_settings('home'); ?>">Lost?</a></p>
        <div class="content">
        <p><span class="dropcap">W</span>e regret to inform you that the article or post you were looking is nowhere to be found. We agree that this is rather unfortunate. Luckily for you, we've implemented a handy <em>search box</em> into the top right hand corner or perhaps you'd rather check out our <a href="<?php echo get_settings('home'); ?>">homepage</a>? I can assure you that we are hunting down this 404 bug as you read this and it will be promptly corrected, unless you purposely typed in an incorrect URL, in that case, cut it out!</p>
        <p class="tags"><em>TAGS:</em> <a href="<?php echo get_settings('home'); ?>">Are</a>, <a href="<?php echo get_settings('home'); ?>">You</a>, <a href="<?php echo get_settings('home'); ?>">Lost?</a></p>
        </div>
    </div>
    <?php endif; ?>
    </div>

    <?php get_sidebar(); ?>
    
    <div class="clr"></div>
    
    <?php get_footer(); ?>