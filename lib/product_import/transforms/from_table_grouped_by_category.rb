
class ProductImport::Transforms::FromTableGroupedByCategory < ProductImport::Framework::Transform
  def inititalize(opts)
    super

    @last_row = nil
    @last_header_row = nil
    @last_category = nil
  end

  def category_column
    opts[:category_column]
  end


  def transform_step(row)
    if opts[:header_row_pattern].zip(row).all?{|pat, actual| !pat || pat === actual}

      @last_category = @last_row[category_column]
      @last_header_row = row

    elsif @last_category

      hash = Hash[@last_header_row.zip(row)]

      if opts[:required_headers].any?{|k| not hash[k]}
        # skip

      else
        hash['category'] = @last_category
        continue hash
      end

    end

    @last_row = row
  end
end
