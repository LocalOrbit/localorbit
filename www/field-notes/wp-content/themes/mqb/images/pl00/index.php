<?php get_header(); ?>

<!-- BEGIN SECTION ONE -->
				
				<div id="PageBody">
				
					<div id="Content">
					
								<?php if (have_posts()) : ?>
							
									<?php while (have_posts()) : the_post(); ?>
							
										<div class="post" id="post-<?php the_ID(); ?>">
											<h2><a href="<?php the_permalink() ?>" rel="bookmark" title="Permanent Link to <?php the_title_attribute(); ?>"><?php the_title(); ?></a></h2>
											<small><?php the_time('F jS, Y') ?> <!-- by <?php the_author() ?> --></small>
							
											<div class="entry">
												<?php the_content('Read the rest of this entry &raquo;'); ?>
											</div>
							
											<p class="postmetadata"><?php the_tags('Tags: ', ', ', '<br />'); ?> Posted in <?php the_category(', ') ?> | <?php edit_post_link('Edit', '', ' | '); ?>  <?php comments_popup_link('No Comments &#187;', '1 Comment &#187;', '% Comments &#187;'); ?></p>
										</div><!-- end "post-<?php the_ID(); ?>" div -->
							
									<?php endwhile; ?>
							
									<div class="navigation">
										<div class="alignleft"><?php next_posts_link('&laquo; Older Entries') ?></div>
										<div class="alignright"><?php previous_posts_link('Newer Entries &raquo;') ?></div>
									</div>
							
								<?php else : ?>
							
									<h2 class="center">Not Found</h2>
									<p class="center">Sorry, but you are looking for something that isn't here.</p>
									<?php include (TEMPLATEPATH . "/searchform.php"); ?>
							
								<?php endif; ?>

					</div><!-- end "Content" div -->
				
<?php get_sidebar(); ?>
					
<!-- BEGIN SECTION TWO -->

						<div id="SubContent">
						
										<div id="SubColumn1">
											<?php if ( !function_exists('dynamic_sidebar') || !dynamic_sidebar("Bottom Left") ) : ?>
												<h2>Tag Cloud</h2>
												<?php wp_tag_cloud(); ?>	
											<?php endif; ?>
										</div><!-- end "SubColumn1" div -->
										
										<div id="SubColumn2">
											<?php if ( !function_exists('dynamic_sidebar') || !dynamic_sidebar("Bottom Middle") ) : ?>
												<h2>RSS Feeds by Category</h2>
												<ul>
													<?php wp_list_categories('feed=RSS'); ?>
												</ul>	
											<?php endif; ?>
										</div><!-- end "SubColumn2" div -->
										
										<div id="SubColumn3">
											<?php if ( !function_exists('dynamic_sidebar') || !dynamic_sidebar("Bottom Right") ) : ?>
												<h2>Meta</h2>
													<ul>
														<?php wp_register(); ?>
														<li><?php wp_loginout(); ?></li>
														<li><a href="http://validator.w3.org/check/referer" title="This page validates as XHTML 1.0 Transitional">Valid <abbr title="eXtensible HyperText Markup Language">XHTML</abbr></a></li>
														<li><a href="http://gmpg.org/xfn/"><abbr title="XHTML Friends Network">XFN</abbr></a></li>
														<li><a href="http://wordpress.org/" title="Powered by WordPress, state-of-the-art semantic personal publishing platform.">WordPress</a></li>
														<?php wp_meta(); ?>
													</ul>
											<?php endif; ?>
										</div><!-- end "SubColumn3" div -->
							
							
						</div><!-- end "SubContent" div -->				
				
				</div><!-- end "PageBody" div -->
			
			</div><!-- end "PageContainer" div -->
			
<?php get_footer(); ?>
