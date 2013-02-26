<?php get_header(); ?>        
        
        <div id="topbanner_arch" class="column span-14">   <!-- start top banner -->
            <div class="pagetitle">
                // author archive
            </div>
        </div>   <!-- end top banner -->
        
        
        <div id="arch_content" class="column span-14">   <!-- start home_content -->
        
        <?php 
		if(isset($_GET['author_name'])) :
		$curauth = get_userdatabylogin($author_name);
		else :
		$curauth = get_userdata(intval($author));
		endif;
		?>
        
        <?php if (have_posts()) : ?>
        
        	<div class="column span-3 first">        
            	<h2 class="archive_name"><?php echo $curauth->display_name; ?></h2>        
            	
            	<div class="archive_meta">
            		
            		<div class="archive_number">
						<?php echo $curauth->display_name; ?> has written <?php the_author_posts(); ?> posts for <?php bloginfo('name'); ?>
					</div>

					<div class="archive_email">
						<a href="mailto:<?php the_author_email(); ?>">Email the author</a>
					</div>
            	
            	</div>
            </div>
            
                        
            <div class="column span-8">
            
            <?php while (have_posts()) : the_post(); ?>
            
            	<div class="archive_post_block">
            		<h3 class="archive_title" id="post-<?php the_ID(); ?>"><a href="<?php the_permalink(); ?>" rel="bookmark" title="Permanent Link to <?php the_title(); ?>"><?php the_title(); ?></a></h3>
            		
            		<div class="archive_post_meta">By <?php the_author_posts_link(); ?> <span class="dot">&sdot;</span> <?php the_time('F j, Y'); ?> <span class="dot">&sdot;</span> <a href="<?php comments_link(); ?>"><?php comments_number('Post a comment','One comment','% comments'); ?></a></div>
            		
            		<?php the_excerpt(); ?>
            	</div>
            	
            	<?php endwhile; ?>

				<div class="navigation">
					<p><?php next_posts_link('&laquo; Previous') ?> &nbsp; <?php previous_posts_link('Next &raquo;') ?></p>
				</div>

				<?php else : ?>

					<p>Lost? Go back to the <a href="<?php echo get_option('home'); ?>/">home page</a>.</p>

				<?php endif; ?>
            	
            </div>
            
            <?php get_sidebar(); ?>
        
        </div>   <!-- start home_content -->
        
        
<?php get_footer(); ?>
