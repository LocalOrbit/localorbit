
class ProductImport::Transforms::LookUpOrganization < ProductImport::Framework::Transform
  def transform_step(row)

  	if organizations_map.key? row['organization']
  		row['organization_id'] = organizations_map[row['organization']]
  		continue row
  	else
  		reject "Could not find organization with name #{row['organization']}"
  	end

  end


  def organizations_map
    @organizations_map ||=
      begin
      	market = Market.find(importer.opts[:market_id])
        organizations = market.organizations.where(can_sell:true)
        Hash[organizations.map{ |o| [o.name,o.id] }]
      end
	end



end
