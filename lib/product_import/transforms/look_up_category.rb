
class ProductImport::Transforms::LookUpCategory < ProductImport::Framework::Transform
  def transform_step(row)

    if cat = category_for_name(row['category'])
      row['category_id'] = cat
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

  def category_for_name(n)
    if n.present? && !category_map.key?(n)
      parts = n.split(/(?:\s*>\s*)+/).reject{|n| n.blank?}
      category_map[n] = nil

      # If we have a All > Foo > Bar spec, go and look it up and cache it.
      if (2..3).include? parts.length

        # All is optional, but length three must start with All
        if parts.length == 3
          if parts[0] == "All"
            parts.shift
          else
            return nil
          end
        end

        potential_matches = Category.where(depth: 2, name: parts.last).includes(:parent)

        potential_matches.each do |m|
          categories = [m.parent, m]
          names = categories.map(&:name)
          if parts == names
            category_map[n] = m.id
            break
          end
        end
      end
    end

    return category_map[n]
  end
end
