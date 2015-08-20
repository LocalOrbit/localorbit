
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

    parts = row.values_at(*opts[:from])
    if parts[1..-1].any?(&:blank?)
      row['contrived_key'] = nil
    elsif parts[0].blank?
      row['contrived_key'] = ExternalProduct.contrive_key(parts[1..-1].map! {|p| p.upcase}) # control for case so that won't differentiate names of products
      # The problem here is only that if a supplier suddenly starts using a product code and putting it into the filled templates they give LO, the updates for that supplier won't work right
      # So we'll have to ultimately check for, if in the database, is there a product code? To decide whether to do this. (Not ideal)
      # If not, v dependent on humans --
      # But if ever a serious issue, probably correctable with (add'l) humans who know SQL/ActiveRecord.
      # We'll have to be careful as always about what we assume -- but we already do because we're importing data.
    else
      row['contrived_key'] = ExternalProduct.contrive_key([parts[0]]) # Use only the product code if they provide it (because we started doing that and want to maintain the history). It expects an array.
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
