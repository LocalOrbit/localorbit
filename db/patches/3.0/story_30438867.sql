update template_options set default_value = concat_ws('','/',default_value) 
where name like '%image%';

update template_options set default_value ='Local Orbit' where name='footer-col1-label';

update template_options set default_value ='Home' where name='footer-col1-link1-label';
update template_options set default_value ='/index.php' where name='footer-col1-link1-href';

update template_options set default_value ='Features' where name='footer-col1-link2-label';
update template_options set default_value ='/homepage/features.php' where name='footer-col1-link2-href';

update template_options set default_value ='FAQ' where name='footer-col1-link3-label';
update template_options set default_value ='/homepage/faq.php' where name='footer-col1-link3-href';

update template_options set default_value ='' where name='footer-col1-link4-label';
update template_options set default_value ='' where name='footer-col1-link4-href';
update template_options set default_value ='' where name='footer-col1-link5-label';
update template_options set default_value ='' where name='footer-col1-link5-href';
update template_options set default_value ='' where name='footer-col1-link6-label';
update template_options set default_value ='' where name='footer-col1-link6-href';
update template_options set default_value ='' where name='footer-col1-link7-label';
update template_options set default_value ='' where name='footer-col1-link7-href';
update template_options set default_value ='' where name='footer-col1-link8-label';
update template_options set default_value ='' where name='footer-col1-link8-href';

update template_options set default_value ='/homepage/about.php' where name='footer-col2-link1-href';
update template_options set default_value ='/homepage/team.php' where name='footer-col2-link2-href';
update template_options set default_value ='/homepage/work_with_us.php' where name='footer-col2-link3-href';


update template_options set default_value='Javascript:{$(''#overlay,#popup3,#popup_closer'').fadeIn(150);}' where name='footer-col4-link2-href';