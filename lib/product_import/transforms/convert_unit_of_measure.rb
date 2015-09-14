
class ProductImport::Transforms::ConvertUnitOfMeasure < ProductImport::Framework::Transform
  PIECE_UOMS = %w(piece pc)
  POUND_UOMS = %w(pound lb)
  CASE_UOMS = %w(case cs)
  SUPPORTED_UOMS = [PIECE_UOMS, POUND_UOMS, CASE_UOMS].flatten # TODO this will need to be more adaptable for true multi-unit - TODO expand unit options. Error for wrong one (wrong plural, etc)


  def transform_step(row)
    # Use continue to pass the transformed data onto the next stage.
    uom = row['uom'].downcase

    if SUPPORTED_UOMS.include?(uom) # TODO will need to change supported uoms, possibly to method to check.
      if CASE_UOMS.include?(uom)
        multiply_price(row, by: 1)
        continue row

      elsif PIECE_UOMS.include?(uom)
        count = fill_count(row)

        if count
          multiply_price(row, by: count)
          continue row
        end

      elsif POUND_UOMS.include?(uom)
        count = fill_count(row)
        lbs = fill_pounds(row)

        if count && lbs
          multiply_price(row, by: count * lbs)
          continue row
        else
          reject "Didn't know how to interpret unit line #{row['unit']}. Got count: #{count}, lbs: #{lbs}"
        end
      end


      # To flag this row as invalid
      #   reject "the reason this failed"
    else
      reject "Unknown unit of measure #{uom}"
    end
  end

  def fill_count(row)
    pkg = row['unit']
    if pkg =~ %r{(\d+)\s*[/xX]}
      cnt = $1.to_i
      if cnt.zero?
        return nil
      else
        row['qty_per_case'] = cnt
        return cnt
      end
    else
        row['qty_per_case'] = 1
        return 1
    end
  end



  def fill_pounds(row)
    pkg = row['unit']
    if pkg =~ %r{((?:\d+\.)?\d+)?\s*(#|lb|kg|oz|ounce)}i
      unit = $2
      case unit.downcase
      when "kg"
        unit_multiplier = 2.2
      when "oz", "ounce"
        unit_multiplier = 0.0625
      else
        unit_multiplier = 1
      end

      if $1.blank?
        cnt = 1
      else
        cnt = $1.to_f
      end

      if cnt.zero?
        return nil
      else
        weight = cnt * unit_multiplier
        row['lbs_per_item'] = weight
        return weight
      end

    else
      return nil
    end
  end

  def multiply_price(row, by:)
    row['original_price'] = row['price']
    row['price'] = "%.2f" % [row['price'].to_f * by]
  end

end
