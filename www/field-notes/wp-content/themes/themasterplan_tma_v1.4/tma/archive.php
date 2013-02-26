<?php get_header(); ?>        
        
        <div id="topbanner_arch" class="column span-14">   <!-- start top banner -->
            <div class="pagetitle">
                // archives
            </div>
        </div>   <!-- end top banner -->
        
        
        <div id="arch_content" class="column span-14">   <!-- start home_content -->
        
        <?php if (have_posts()) : ?>
        
        	<div class="column span-3 first">
        	
        		<?php if (is_category()) { ?>
        	
            	<h2 class="archive_name"><?php echo single_cat_title(); ?></h2>        
            	
            	<div class="archive_meta">
            	
            		<div class="archive_feed">
            			<?php $cat_obj = $wp_query->get_queried_object(); $cat_id = $cat_obj->cat_ID; echo '<a href="'; get_category_rss_link(true, $cat, ''); echo '">RSS feed for this section</a>'; ?>            			
            		</div>

            		<?php $cat_count = $cat_obj->category_count; ?>
            		<div class="archive_number">
            			This category contains <?php echo $cat_count . ($cat_count==1?" post":" posts") ?>
            		</div>           		
            	
            	</div>

				<?php } elseif (is_tag()) { ?>
        	
            	<h2 class="archive_name"><?php single_tag_title(); ?></h2>        
            	
            	<div class="archive_meta">
            	
            		<div class="archive_number">
            			This tag is associated with <?php $tag = $wp_query->get_queried_object(); echo $tag->count; ?> posts
            		</div>           		
            	
            	</div>
            	
				<?php } elseif (is_day()) { ?>
				<h2 class="archive_name">Archive for <?php the_time('F jS, Y'); ?></h2>

				<?php } elseif (is_month()) { ?>
				<h2 class="archive_name">Archive for <?php the_time('F, Y'); ?></h2>

				<?php } elseif (is_year()) { ?>
				<h2 class="archive_name">Archive for <?php the_time('Y'); ?></h2>
				
				<?php } ?>
				
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
					<p><?php next_posts_link('&laquo; Previous') ?> &#8212; <?php previous_posts_link('Next &raquo;') ?></p>
				</div>

				<?php else : ?>

					<p>Lost? Go back to the <a href="<?php echo get_option('home'); ?>/">home page</a>.</p>

				<?php endif; ?>
            	
            </div>
            
            <?php get_sidebar(); ?>
        
        </div>   <!-- start home_content -->
        
        
<?php get_footer(); ?>
