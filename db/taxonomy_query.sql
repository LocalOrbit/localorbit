-- The current product migration script requires that category_id be manually added into the template CSV.
-- This is a query to grab the categories with a heirarchical list to help the human filling out the template decide what they want to put in the column

WITH RECURSIVE category_taxonomy
AS
(
    SELECT
        categories.name, id, parent_id, categories.name::text AS taxonomy
    FROM categories WHERE parent_id IS NULL
    UNION
    SELECT
        child.name, child.id, child.parent_id, category_taxonomy.taxonomy || ' > ' || child.name::text AS taxonomy
    FROM
        category_taxonomy
        JOIN categories child ON child.parent_id = category_taxonomy.id
)
SELECT name, id, taxonomy FROM category_taxonomy ORDER BY taxonomy;