

INSERT INTO migrations (tag, version_id, pt_ticket_no) VALUES ('4.071', '005', '');


ALTER TABLE categories  ADD order_by int;

UPDATE categories SET order_by = 1 WHERE cat_name = 'Fruits';
UPDATE categories SET order_by = 2 WHERE cat_name = 'Vegetables';
UPDATE categories SET order_by = 3 WHERE cat_name = 'Dairy, Cheese & Eggs';
UPDATE categories SET order_by = 4 WHERE cat_name = 'Meat & Poultry';
UPDATE categories SET order_by = 5 WHERE cat_name = 'Fish & Seafood';
UPDATE categories SET order_by = 6 WHERE cat_name = 'Dried Fruits & Nuts';
UPDATE categories SET order_by = 7 WHERE cat_name = 'Breads & Baked Goods';
UPDATE categories SET order_by = 8 WHERE cat_name = 'Flours & Baking Needs';
UPDATE categories SET order_by = 9 WHERE cat_name = 'Pasta, Rice, Grains & Dried Beans';
UPDATE categories SET order_by = 10 WHERE cat_name = 'Prepared Foods';
UPDATE categories SET order_by = 11 WHERE cat_name = 'Snacks';
UPDATE categories SET order_by = 12 WHERE cat_name = 'Chocolate & Sweets';
UPDATE categories SET order_by = 13 WHERE cat_name = 'Condiments, Sauces & Sweeteners';
UPDATE categories SET order_by = 14 WHERE cat_name = 'Oils & Vinegars';
UPDATE categories SET order_by = 15 WHERE cat_name = 'Spices & Seasonings';
UPDATE categories SET order_by = 16 WHERE cat_name = 'Beverages';
UPDATE categories SET order_by = 17 WHERE cat_name = 'Flowers & Plants';
UPDATE categories SET order_by = 18 WHERE cat_name = 'Agriculture Supplies';
UPDATE categories SET order_by = 19 WHERE cat_name = 'Livestock';
UPDATE categories SET order_by = 20 WHERE cat_name = '1044 2 Art, Crafts & Pottery';
UPDATE categories SET order_by = 21 WHERE cat_name = '500 2 Health & Beauty';
UPDATE categories SET order_by = 22 WHERE cat_name = '592 2 Household';
UPDATE categories SET order_by = 23 WHERE cat_name = '647 2 Pet Products';
UPDATE categories SET order_by = 24 WHERE cat_name = '656 2 Cookbooks';
UPDATE categories SET order_by =25  WHERE cat_name = '168 2 Gift Cards';
UPDATE categories SET order_by =26 WHERE cat_name = 'Membership';