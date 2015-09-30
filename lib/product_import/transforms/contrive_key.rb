
class ProductImport::Transforms::ContriveKey < ProductImport::Framework::Transform
  def initialize(opts={})
    super 
    @contrived_keys = {}
  end


  def transform_step(row)
    if opts[:skip_if_present] && row['contrived_key']
      continue row
      return
    end

    parts = row.values_at(*opts[:from]) # TODO write up scenarios (distributor, product code, along for ride, break case feature. We are making choice to bring prodcodes along for the ride. Products with diff units might have same product code, which is not the current situation. Or might have same product with diff unit that get diff product codes (required), but we don't care. WE care about 3 lbs vs 6 lbs.)
    if parts.any?(&:blank?)#parts[1..-1].any?(&:blank?)
      row['contrived_key'] = nil
    else #parts[0].blank?
      row['contrived_key'] = ExternalProduct.contrive_key(parts.map! {|p| p.to_s.upcase}) # control for case so that won't differentiate names of products
    # TODO: regenerate contrived key column before making this change in order to keep from getting product duplicates.
    # else
    #   row['contrived_key'] = ExternalProduct.contrive_key([parts[0]]) # Use only the product code if they provide it (because we started doing that and want to maintain the history). It expects an array.
    end

    if row['contrived_key']
      if @contrived_keys[row['contrived_key']]
        reject "This product's contrived key already exists: #{row['contrived_key']}"
      else
        @contrived_keys[row['contrived_key']] = true
        continue row
      end
    else
      reject "Couldn't contrive a key, some fields are blank." # don't care if product code is blank, we can solve that problem.
    end
  end
end
