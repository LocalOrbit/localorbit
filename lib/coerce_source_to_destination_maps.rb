class CoerceSourceToDestinationMaps

  def self.call(source_to_destination_maps)
    # remove empty values TODO: use transform_values! in rails 4.2.1 or ruby 2.4
    source_to_destination_maps.update(source_to_destination_maps) {|k,v| v.select(&:present?).map(&:to_i) }
    source_to_destination_maps.transform_keys! {|k| k.to_i }
  end

end
