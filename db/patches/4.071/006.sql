INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.071', '006', '51747709');

delete from phrases where label='note:totals_table_current_view';

insert into phrases (pcat_id,label,edit_type,default_value) values (5,'note:totals_table_current_view','textarea','The total below is a sum of the visible rows for the report you''ve selected. If you''d like to view the full report totals, select &quot;Show all rows&quot; in the drop down.');