class ProductImport::Transforms::HandleBreakCase < ProductImport::Framework::Transform
  def transform_step(row)
    if row['break_case'].upcase == "Y" 
    	if not row['break_case_unit'] and row['break_case_unit_description'] and row['break_case_price']
    		reject "Missing break case unit information. Check rows."
    	elsif row['break_case_unit'] == row['unit'] and row['break_case_unit_description'] == row['unit_description']
    		reject "Units for break case identical to original product units."
    	end
			new_row = row
    	new_row['unit'] = row['break_case_unit']
    	new_row['unit_description'] = row['break_case_unit_description']
    	new_row['price'] = row['break_case_price'] # TODO: need to be validating break case price and also to properly alias those optional columns
    	continue new_row # TODO this will work (check)
    end
    continue row
  end
end