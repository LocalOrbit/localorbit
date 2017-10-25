module CSVExport
  class CSVImportProductExportJob < Struct.new(:user, :subdomain, :ids) # pass in the datafile like is done right now in uploadcontroller, i.e.

    def enqueue(job)
    end

    def success(job)
    end

    def error(job, exception)
      puts exception
    end

    def failure(job)
    end

    def perform
      products = Product.where(id: ids).order(:name)
      market = Market.find_by_subdomain(subdomain)
      csv = CSV.generate do |f|
        buysell_headers =  ["Organization","Market Subdomain","Product Name","Category Name","Short Description","Long Description","Product Code","Unit Name","Unit Description","Price","Current Inventory","New Inventory","Product ID"]
        consignment_headers =  ["Organization","Market Subdomain","Product Name","Category Name","Short Description","Product Code","Unit Name","Unit Quantity","Unit Description","Price","Net Price", "Current Inventory","New Inventory","Parent Product Name","Organic","Product ID"]

        market.is_consignment_market? ? f << consignment_headers : f << buysell_headers

        products.decorate.each do |product|
          if market.is_consignment_market?
            parent_product_name = (product.parent_product_id.nil? || product.parent_product_id == 0) ? "" : Product.find(product.parent_product_id).name
            organic = product.organic ? 1:0
            f << [
                product.organization_name,
                subdomain,
                product.name,
                product.second_level_category.name,
                product.short_description,
                product.code,
                product.unit.singular,
                market.is_consignment_market? ? product.unit_quantity : "",
                product.unit_description,
                product.prices.view_sorted_export.empty? ? 0 : product.prices.view_sorted_export.decorate.map(&:min_1_qty)[0],
                product.prices.view_sorted_export.empty? ? 0 : product.prices.view_sorted_export.decorate.map(&:rounded_net_price)[0],
                product.use_simple_inventory && product.lots.count == 1 ? product.lots[0].quantity : "Adv Inv",
                "",
                market.is_consignment_market? ? parent_product_name : "",
                market.is_consignment_market? ? organic : "",
                product.id,
            ]
          else
            f << [
                product.organization_name,
                subdomain,
                product.name,
                product.second_level_category.name,
                product.short_description,
                product.long_description,
                product.code,
                product.unit.singular,
                product.unit_description,
                product.prices.view_sorted_export.empty? ? 0 : product.prices.view_sorted_export.decorate.map(&:min_1_qty)[0],
                product.use_simple_inventory && product.lots.count == 1 ? product.lots[0].quantity : "Adv Inv",
                "",
                product.id,
            ]
          end
        end
      end

      # Send via email
      ExportMailer.delay.export_success(user.email, 'product', csv.encode!('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: ''))
    end

  end
end