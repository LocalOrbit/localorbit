
class ProductImport::Transforms::LookUpUnit < ProductImport::Framework::Transform
  def transform_step(row)
    if id = unit_map[row['unit']]
      row['unit_id'] = id
      continue row
    else
      reject "Could not find unit with name #{row['unit']}"
    end

  end

  def unit_map
    @unit_map ||= Hash.new do |h,k|
      u = Unit.find_by_plural(k)
      h[k] = u && u.id
    end
  end
end
