
class ProductImport::Transforms::LookUpCategory < ProductImport::Framework::Transform
  def transform_step(row)

  	if category_map.key? row['category']
  		row['category_id'] = category_map[row['category']]
  		continue row
  	else
  		reject "Could not find category with name #{row['category']}"
  	end

  end

  def category_map
    @category_map ||=
      begin
        categories = Category.where(depth:2)
        Hash[categories.map{ |c| [c.name,c.id] }]
      end
  end
end
